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

import Foundation
import AmbrosusSDK

/// Tracks User Session changes and stores session data for later use
final class AccountManager {

    static let signedInUserStoredKey = "signedInUserStoredKey"

    static let sharedInstance = AccountManager()

    var storedUserPublicKey: String? {
        return UserDefaults.standard.string(forKey: AccountManager.signedInUserStoredKey)
    }

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeSession), name: AMBUserSession.userSignedInNotification, object: nil)
    }

    @objc func storeSession() {
        let signedInUserPublicKey = AMBUserSession.sharedInstance.signedInUserPublicKey
        UserDefaults.standard.set(signedInUserPublicKey, forKey: AccountManager.signedInUserStoredKey)
    }
}
