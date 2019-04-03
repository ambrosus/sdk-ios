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

public class AMBAssetContent: NSObject {

    ///  Id data submodel , contains timestamp and creator public key
    public let idData: AMBAssetIdData
    ///  A signature unique to this event, used to verify authenticity
    public let signature: String

    init?(json: [String: Any]?) {
        guard let json = json,
            let signature = json[AMBConstants.signatureKey] as? String,
            let idDataDict = json[AMBConstants.idDataKey] as? [String: Any],
            let idData = AMBAssetIdData(json: idDataDict) else {
                return nil
        }
        self.signature = signature
        self.idData = idData
    }

    public override init() {
        self.idData = AMBAssetIdData()
        self.signature = ""
        super.init()
    }

}
