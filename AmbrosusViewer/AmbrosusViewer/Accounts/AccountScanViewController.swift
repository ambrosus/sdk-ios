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

class AccountScanViewController: UIViewController {

    fileprivate var scanner: AMBScanViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Scan Account"
        setupScanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeScanner()
    }

    func setupScanner() {
        scanner = AMBScanViewController()
        scanner?.delegate = self
        scanner?.setup(with: self, scannerType: .account)
    }

    func removeScanner() {
        scanner?.delegate = nil
        scanner?.stop()
    }

    private func presentAccountScanFailureAlert(with query: String, didExitAlert: @escaping () -> Void) {
        let alert = DialogBuilder(style: .alert)
            .setTitle("Scanned \(query) code")
            .setMessage("Failed to find Ambrosus Account from request with query: " + query)
            .addAction("OK", completion: { _ in
                self.removeScanner()
                self.setupScanner()
                didExitAlert()
            })
            .build()
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func presentScanSuccessAlert(with address: String) {
        let alert = DialogBuilder(style: .alert)
            .setTitle("Account Added!")
            .setMessage("Account with address: \(address) added successfully!")
            .addAction("OK", completion: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .build()
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func performAccountScan(with query: String?, scanResult: @escaping (Bool) -> Void) {
        guard let query = query else {
            presentAccountScanFailureAlert(with: "") {
                scanResult(false)
            }
            return
        }
        let address = extractAccountData(from: query)
        AccountsManager.sharedInstance.signIn(with: address)
        if !AccountsManager.sharedInstance.isSignedIn() {
            presentAccountScanFailureAlert(with: query) {
                scanResult(false)
            }
        } else {
            self.showSuccessAlert()
        }
    }

    private func showSuccessAlert() {
        let alert = DialogBuilder(style: .alert)
            .setMessage("Your login successes")
            .addAction("Ok", completion: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .build()
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func extractAccountData(from data: String) -> String {
        var key = data.replacingOccurrences(of: "type=ambrosus.account", with: "")
        key = key.replacingOccurrences(of: "&account=", with: "")
        return key
    }
}

extension AccountScanViewController: AMBScanViewControllerDelegate {
    func scanner(_ controller: AMBScanViewController, didCaptureCode code: String, type: String, codeResult: @escaping (Bool) -> Void) {
        performAccountScan(with: code) { result in
            codeResult(result)
        }
    }
}
