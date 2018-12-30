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

class ViewController: NSViewController {
    
    @IBOutlet weak var numberResultsComboBox: NSComboBox!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var searchTextField: NSTextField!
    
    @IBOutlet var searchResultsController: NSArrayController!
  
    @objc dynamic var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let itemPrototype = storyboard?.instantiateController(withIdentifier: "collectionViewItem") as! NSCollectionViewItem
        collectionView.itemPrototype = itemPrototype
    }
    
    @IBAction func searchClicked(_ sender: AnyObject) {
        guard !searchTextField.stringValue.isEmpty else { return }
        
        guard let resultsNumber = Int(numberResultsComboBox.stringValue) else { return }
        loading = true
        iTunesRequestManager.getSearchResults(searchTextField.stringValue,
                                              results: resultsNumber,
                                              langString: "en_US") { [weak self] result in
                                                guard let strongSelf = self else { return }
                                                strongSelf.loading = false
                                                DispatchQueue.main.async {
                                                  switch result {
                                                  case .success(data: let results):
                                                    let rankedResults = results
                                                      .enumerated()
                                                      .map({ index, element -> SearchResult in
                                                        element.rank = index + 1
                                                        return element
                                                      })
                                                    strongSelf.searchResultsController.content = rankedResults
                                                  case .failure(let error):
                                                    print("failure: \(error)")
                                                  }
                                                }
        }
    }
  
  @objc
  func tableViewSelectionDidChange(_ notification: NSNotification) {
    guard let searchResult = searchResultsController.selectedObjects.first as? SearchResult else { return }
    searchResult.loadIcon()
    searchResult.loadScreenShots()
  }
}

extension ViewController: NSTextFieldDelegate {
  func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    if commandSelector == #selector(insertNewline(_:)) {
      searchClicked(searchTextField)
    }
    return false
  }
}
