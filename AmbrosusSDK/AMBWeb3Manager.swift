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
import os.log

@objcMembers public final class AMBWeb3Manager: NSObject {

    public static let sharedInstance = AMBWeb3Manager()
    public var account: Account?

    /// Enables client side signing with AMB-NET, operations on private key are only done locally
    ///
    /// - Parameter privateKey: The private key for the AMB-NET account
    public func setAccount(withPrivateKey privateKey: String) {
        let privateKeyData = SecureData.hexString(toData: privateKey)
        account = Account(privateKey: privateKeyData)
    }

    internal func generateSignature(for data: Any) -> String? {
        guard let message = serialize(value: data) else {
            return nil
        }
        return generateSignature(fromMessage: message)
    }

    private func generateSignature(fromMessage message: String) -> String? {
        let data = message.data(using: .utf8)
        guard let account = account else {
            os_log("%@", log: ambLog, type: .debug, "You must set an account in order to sign messages.")
            return nil
        }
        guard let signature = account.signMessage(data) else {
            os_log("%@", log: ambLog, type: .debug, "Message was not valid, couldn't sign.")
            return nil
        }
        return signatureString(from: signature)
    }

    internal func getHash(for data: Any) -> String? {
        guard let message = serialize(value: data) else {
            return nil
        }
        let signing = "\u{19}Ethereum Signed Message:\n\(message.count)\(message)"
        let data = signing.data(using: .utf8)
        let dataOne = "0x" + SecureData.keccak256(data).hexEncodedString()
        return dataOne
    }

    internal func serialize(value: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(value) else {
            os_log("%@", log: ambLog, type: .debug, "Unable to serialize data")
            return nil
        }
        do {
            let options: JSONSerialization.WritingOptions = {
                if #available(iOS 11.0, *) {
                    return .sortedKeys
                } else {
                    return []
                }
            }()
            let data = try JSONSerialization.data(withJSONObject: value, options: options)
            guard var serializedString = String(data: data, encoding: .utf8) else {
                os_log("%@", log: ambLog, type: .debug, "Unable to encode data to UTF-8")
                return nil
            }
            serializedString = serializedString.replacingOccurrences(of: "\\/", with: "/")
            return serializedString
        } catch {
            os_log("%@", log: ambLog, type: .debug, "Unable to serialize data")
            return nil
        }
    }

    private func signatureString(from signature: Signature) -> String {
        let formattedV = signature.v + 27
        let hexV = String(format: "%02x", formattedV)
        let signatureString = "0x\(signature.r.hexEncodedString())\(signature.s.hexEncodedString())\(hexV)"
        return signatureString
    }
}
