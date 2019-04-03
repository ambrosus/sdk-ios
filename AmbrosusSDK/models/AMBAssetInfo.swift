//
//  Copyright: Ambrosus Inc.
//  Email: tech@ambrosus.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
// (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/// An array of type [String: [String: Any]] useful for formatting complex AMB-Net Data
/// to an easy to use Data Source for display, formattedSections are accessible from both assets and events
public typealias AMBFormattedSections = [[String: [String: Any]]]

/// Submodel for event which contains Asset information
public struct AMBAssetInfo {

    /// The Asset name
    public let name: String
    /// A dictionary which contains all images urls
    public let imageDictionary: [String: Any]
    /// Main image url
    public let imagePath: String

    init?(json: [String: Any]?) {
        guard let json = json,
            let name = json[AMBConstants.nameKey] as? String,
            let imageDictionary = json[AMBConstants.imagesKey] as? [String: Any],
            let imagesDefaultDictionary = imageDictionary[AMBConstants.defaultKey] as? [String: Any],
            let imagePath = imagesDefaultDictionary[AMBConstants.urlKey] as? String else {
                return nil
        }
        self.name = name
        self.imageDictionary = imageDictionary
        self.imagePath = imagePath
    }
}
