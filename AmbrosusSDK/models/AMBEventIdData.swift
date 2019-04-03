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

public class AMBEventIdData: AMBIdData {

    /// The unique identifier for the asset this event happened to
    public let assetId: String
    /// Determines who has access to view this event, 0 = public. The higher the level the more restricted the event is
    public let accessLevel: Int
    public let dataHash: String

    override init?(json: [String: Any]?) {
        guard let json = json,
            let assetId = json[AMBConstants.assetIdKey] as? String,
            let accessLevel = json[AMBConstants.accessLevelKey] as? Int,
            let dataHash = json[AMBConstants.dataHashKey] as? String else {
                return nil
        }
        self.assetId = assetId
        self.accessLevel = accessLevel
        self.dataHash = dataHash
        super.init(json: json)
    }

    public override init() {
        self.assetId = ""
        self.accessLevel = 0
        self.dataHash = ""
        super.init()
    }

}
