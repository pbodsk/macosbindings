/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

enum Result<Value> {
  case success(data: Value)
  case failure(Error)
}

struct iTunesRequestManager {
  static func getSearchResults(_ query: String, results: Int, langString :String, completionHandler: @escaping (Result<[SearchResult]>) -> Void) {
    var urlComponents = URLComponents(string: "https://itunes.apple.com/search")
    let termQueryItem = URLQueryItem(name: "term", value: query)
    let limitQueryItem = URLQueryItem(name: "limit", value: "\(results)")
    let mediaQueryItem = URLQueryItem(name: "media", value: "software")
    urlComponents?.queryItems = [termQueryItem, mediaQueryItem, limitQueryItem]
    
    guard let url = urlComponents?.url else {
      return
    }
    
    let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
      guard let data = data else {
        completionHandler(.success(data: []))
        return
      }
      do {
        /*
        guard let itunesData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] else {
          return
        }
        print(itunesData)
        */
        let decoder = JSONDecoder()
        let itunesResults = try decoder.decode(ITunesResults.self, from: data)
        if itunesResults.results.isEmpty {
          completionHandler(.success(data: []))
        } else {
          completionHandler(.success(data:itunesResults.results))
        }
      } catch {
        completionHandler(.failure(error))
      }
      
    })
    task.resume()
  }
  
  static func downloadImage(_ imageURL: URL, completionHandler: @escaping (Result<NSImage?>) -> Void) {
    let task = URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) -> Void in
      guard let data = data , error == nil else {
        completionHandler(.failure(error!))
        return
      }
      let image = NSImage(data: data)
      completionHandler(.success(data: image))

    })
    task.resume()
  }
}
