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
import os.log

@objcMembers public final class AMBUserSession: NSObject {

    public static let userSignedInNotification: Notification.Name = Notification.Name("userSignedInNotification")

    /// The primary instance of AMBUserSession
    public static let sharedInstance = AMBUserSession()

    /// Returns the signed in user's id if a user is signed in
    public var signedInUserPublicKey: String?

    /// If an AMBAccount is currently signed in
    public var isSignedIn: Bool = false

    /// Creates an account and returns a local instance from AMB-NET
    ///
    /// - Parameters:
    ///   - address: The ERC20 address with which to generate the account
    ///   - canRegisterAccounts: Whether the account should be capable of registering others
    ///   - accessLevel: The permissions level the account should have - default: 0
    ///   - completion: The local instance of the account
    public func createAccount(address: String, canRegisterAccounts: Bool = false, accessLevel: Int = 0, completion: @escaping (AMBAccount?, String?) -> Void) {
        let registerAccountPermission = canRegisterAccounts ? [AMBConstants.registerAccountKey] : []
        var permissions = [AMBConstants.createEntityKey]
        permissions.append(contentsOf: registerAccountPermission)

        let attributes: [String: Any] = [
            AMBConstants.addressKey: address,
            AMBConstants.permissionsKey: permissions,
            AMBConstants.accessLevelKey: accessLevel
        ]
        let path = AMBNetwork.getBaseUrlPath() + "accounts"
        let authorizationType = AuthorizationType.token(AMBNetwork.authorizationToken ?? "")
        AMBNetwork.postRequest(path: path, attributes: attributes, authorizationType: authorizationType, completion: { data, _ in
            guard let data = data as? [String: Any] else {
                let errorMsg = AMBErrorsHandler.unableToGenerateAccountErrorString
                os_log("%@", log: ambLog, type: .debug, errorMsg)
                completion(nil, errorMsg)
                return
            }
            let account = AMBAccount(json: data)
            completion(account, nil)
        })
    }

    public func storeAccount(_ account: AMBAccount) {
        AMBDataStore.sharedInstance.accountsStore.add(account)
    }

    public func signIn(account: AMBAccount) {
        signedInUserPublicKey = account.publicKey
        isSignedIn = true
        NotificationCenter.default.post(name: AMBUserSession.userSignedInNotification, object: nil)
    }

    public func signOut() {
        signedInUserPublicKey = nil
        isSignedIn = false
    }
}
