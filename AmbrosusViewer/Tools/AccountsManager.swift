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
import AmbrosusSDK

class AccountsManager: NSObject {
    public static let sharedInstance = AccountsManager()

    private var privateKey = String()
    private var publicKey = String()

    public func signIn(with yourPrivateKey: String) {
        AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey: yourPrivateKey)
        if let address = AMBWeb3Manager.sharedInstance.account?.address.checksumAddress {
            publicKey = address
            privateKey = yourPrivateKey
            AMBUserSession.sharedInstance.isSignedIn = true
        } else {
            AMBUserSession.sharedInstance.isSignedIn = false
        }
    }

    public func signOut() {
        AMBUserSession.sharedInstance.signOut()
        privateKey = String()
        publicKey = String()
        SampleFetcher.sharedInstance.signOut()
    }

    public func signInWithDemoModel(with account: AMBAccount) {
        AMBUserSession.sharedInstance.signIn(account: account)
        SampleFetcher.sharedInstance.setAccountKey(with: account)
    }

    public func isSignedIn() -> Bool {
       return AMBUserSession.sharedInstance.isSignedIn
    }

    public func getPrivateKey() -> String {
        return privateKey
    }

    public func getPublicKey() -> String {
        return publicKey
    }
}
