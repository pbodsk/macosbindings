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

class ITunesResults: NSObject, Codable {
  var results: [SearchResult]
}

class SearchResult: NSObject, Codable {
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.locale = enUSPosixLocale as Locale
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
  }()
  
  @objc dynamic var artistName = ""
  @objc dynamic var trackName = ""
  @objc dynamic var averageUserRating = 0.0
  @objc dynamic var averageUserRatingForCurrentVersion = 0.0
  @objc dynamic var itemDescription = ""
  @objc dynamic var price = 0.00
  @objc dynamic var releaseDateString: String
  @objc dynamic var releaseDate: Date {
    return SearchResult.dateFormatter.date(from: releaseDateString) ?? Date()
  }
  @objc dynamic var artworkURL: URL?
 // @objc dynamic var artworkImage: NSImage?
  @objc dynamic var screenShotURLs: [URL] = []
  @objc dynamic var screenShots: [NSImage] = []
  @objc dynamic var userRatingCount = 0
  @objc dynamic var userRatingCountForCurrentVersion = 0
  @objc dynamic var primaryGenre = ""
  @objc dynamic var fileSizeInBytesString: String
  @objc dynamic var fileSizeInBytes: Int {
    return Int(fileSizeInBytesString) ?? 0
  }
  //@objc dynamic var cellColor = NSColor.white
  @objc dynamic var rank = 0
  @objc dynamic var artworkImage: NSImage?

  enum CodingKeys: String, CodingKey {
    case artistName
    case trackName
    case averageUserRating
    case averageUserRatingForCurrentVersion
    case itemDescription = "description"
    case price
    case releaseDateString = "releaseDate"
    case artworkURL = "artworkUrl100"
    case screenShotURLs = "screenshotUrls"
    case userRatingCount
    case userRatingCountForCurrentVersion
    case primaryGenre = "primaryGenreName"
    case fileSizeInBytesString = "fileSizeBytes"
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    artistName = try values.decode(String.self, forKey: .artistName)
    trackName = try values.decode(String.self, forKey: .trackName)
    averageUserRating = try values.decodeIfPresent(Double.self, forKey: .averageUserRating) ?? 0.0
    averageUserRatingForCurrentVersion = try values.decode(Double.self, forKey: .averageUserRatingForCurrentVersion)
    itemDescription = try values.decode(String.self, forKey: .itemDescription)
    price = try values.decode(Double.self, forKey: .price)
    releaseDateString = try values.decode(String.self, forKey: .releaseDateString)
    artworkURL = try values.decodeIfPresent(URL.self, forKey: .artworkURL) ?? URL(string: "")
    screenShotURLs = try values.decode([URL].self, forKey: .screenShotURLs)
    userRatingCount = try values.decodeIfPresent(Int.self, forKey: .userRatingCount) ?? 0
    userRatingCountForCurrentVersion = try values.decode(Int.self, forKey: .userRatingCountForCurrentVersion)
    primaryGenre = try values.decode(String.self, forKey: .primaryGenre)
    fileSizeInBytesString = try values.decode(String.self, forKey: .fileSizeInBytesString)
  }
}

extension SearchResult {
  func loadIcon() {
    guard let artworkURL = artworkURL else { return }
    
    if (artworkImage != nil) {
      return
    }
    
    iTunesRequestManager.downloadImage(artworkURL, completionHandler: { (image, error) -> Void in
      DispatchQueue.main.async(execute: {
        self.artworkImage = image
      })
    })
  }
  
  func loadScreenShots() {
    if screenShots.count > 0 {
      return
    }
    
    for screenshotURL in screenShotURLs {
      iTunesRequestManager.downloadImage(screenshotURL, completionHandler: { (image, error) -> Void in
        DispatchQueue.main.async(execute: {
          guard let image = image , error == nil else {
            return;
          }
          
          self.willChangeValue(forKey: "screenShots")
          self.screenShots.append(image)
          self.didChangeValue(forKey: "screenShots")
        })
        
      })
    }
  }
}


class OldResult : NSObject {
  @objc dynamic var rank = 0
  @objc dynamic var artistName = ""
  @objc dynamic var trackName = ""
  @objc dynamic var averageUserRating = 0.0
  @objc dynamic var averageUserRatingForCurrentVersion = 0.0
  @objc dynamic var itemDescription = ""
  @objc dynamic var price = 0.00
  @objc dynamic var releaseDate = Date()
  @objc dynamic var artworkURL: URL?
  @objc dynamic var artworkImage: NSImage?
  @objc dynamic var screenShotURLs: [URL] = []
  @objc dynamic var screenShots = NSMutableArray()
  @objc dynamic var userRatingCount = 0
  @objc dynamic var userRatingCountForCurrentVersion = 0
  @objc dynamic var primaryGenre = ""
  @objc dynamic var fileSizeInBytes = 0
  @objc dynamic var cellColor = NSColor.white
  
  init(dictionary: Dictionary<String, AnyObject>) {
    artistName = dictionary["artistName"] as! String
    trackName = dictionary["trackName"] as! String
    itemDescription = dictionary["description"] as! String
    
    primaryGenre = dictionary["primaryGenreName"] as! String
    if let uRatingCount = dictionary["userRatingCount"] as? Int {
      userRatingCount = uRatingCount
    }
    
    if let uRatingCountForCurrentVersion = dictionary["userRatingCountForCurrentVersion"] as? Int {
      userRatingCountForCurrentVersion = uRatingCountForCurrentVersion
    }
    
    if let averageRating = (dictionary["averageUserRating"] as? Double) {
      averageUserRating = averageRating
    }
    
    if let averageRatingForCurrent = dictionary["averageUserRatingForCurrentVersion"] as? Double {
      averageUserRatingForCurrentVersion = averageRatingForCurrent
    }
    
    if let fileSize = dictionary["fileSizeBytes"] as? String {
      if let fileSizeInt = Int(fileSize) {
        fileSizeInBytes = fileSizeInt
      }
    }
    
    if let appPrice = dictionary["price"] as? Double {
      price = appPrice
    }
    
    let formatter = DateFormatter()
    let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.locale = enUSPosixLocale as Locale
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    if let releaseDateString = dictionary["releaseDate"] as? String {
      releaseDate = formatter.date(from: releaseDateString)!
    }
    if let artURL = URL(string: dictionary["artworkUrl512"] as! String) {
      artworkURL = artURL
    }
    
    if let screenShotsArray = dictionary["screenshotUrls"] as? [String] {
      for screenShotURLString in screenShotsArray {
        if let screenShotURL = URL(string: screenShotURLString) {
          screenShotURLs.append(screenShotURL)
        }
      }
    }
    
    super.init()
  }
  
  func loadIcon() {
    guard let artworkURL = artworkURL else { return }
    
    if (artworkImage != nil) {
      return
    }
    
    iTunesRequestManager.downloadImage(artworkURL, completionHandler: { (image, error) -> Void in
      DispatchQueue.main.async(execute: {
        self.artworkImage = image
      })
    })
  }
  
  func loadScreenShots() {
    if screenShots.count > 0 {
      return
    }
    
    for screenshotURL in screenShotURLs {
      iTunesRequestManager.downloadImage(screenshotURL, completionHandler: { (image, error) -> Void in
        DispatchQueue.main.async(execute: {
          guard let image = image , error == nil else {
            return;
          }
          
          self.willChangeValue(forKey: "screenShots")
          self.screenShots.add(image)
          self.didChangeValue(forKey: "screenShots")
        })
        
      })
    }
  }
  
  override var description: String {
    get {
      return "artist: \(artistName) track: \(trackName) average rating: \(averageUserRating) price: \(price) release date: \(releaseDate)"
    }
  }
}
