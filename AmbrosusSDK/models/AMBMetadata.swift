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

public class AMBMetadata: NSObject {

    /// Identifier of the transaction on which the proof of bundle has been uploaded.
    public let bundleTransactionHash: String?
    /// Timestamp of bundle proof upload
    public let bundleUploadTimestamp: Double?
    /// Content-addressable identifier of the bundle.
    public let bundleId: String
    /// Timestamp of entity proof upload
    public let entityUploadTimestamp: Double?

    init?(json: [String: Any]?) {
        guard let json = json,
            let bundleId = json[AMBConstants.bundleIdKey] as? String else {
                return nil
        }
        self.bundleTransactionHash = json[AMBConstants.bundleTransactionHashKey] as? String
        self.bundleUploadTimestamp = json[AMBConstants.bundleUploadTimestampKey] as? Double
        self.bundleId = bundleId
        self.entityUploadTimestamp = json[AMBConstants.entityUploadTimestampKey] as? Double
    }

    public override init() {
        self.bundleTransactionHash = ""
        self.bundleUploadTimestamp = 0
        self.bundleId = ""
        self.entityUploadTimestamp = 0
        super.init()
    }

}
