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

/// This struct with text of network and other errors.
struct AMBErrorsHandler {
    static let signatureErrorString = "A private key must be set to perform this action. Set private key using AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey:_) method"
    static let validationTokenCreationErrorString = "unable to serialize data, make sure your createdBy field is non empty and timestamp is valid"
    static let base64ErrorString =  "unable to convert token into base64 encoded String, check formatting"
    static let urlInvalidErrorString = "URL Invalid"
    static let imageMissingErrorString = "No image found at URL"
    static let noAssetsForIdErrorString = "Error, no asset found for asset id: "
    static let noEventsForDataErrorString = "Couldn't find events for data"
    static let creaatedByEmptyErrorString = "createdBy field is empty, an Event must have a creator"
    static let getHashErrorString = "Failed to generate hash for supplied data field"
    static let dataEmptyErrorString = "data must have at least one entry in order to be valid"
    static let unableToGenerateAccountErrorString = "Unable to generate account"
    static let noEventsForQueryErrorString = "Error, no events found for query: "
}
