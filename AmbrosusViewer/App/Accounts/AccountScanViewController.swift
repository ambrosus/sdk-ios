//
//  AccountScanViewController.swift
//  AmbrosusViewer
//
//  Created by Stein, Maxwell on 7/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
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
        let alert = UIAlertController(
            title: "Scanned \(query) code",
            message: "Failed to find Ambrosus Account from request with query: " + query,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.removeScanner()
            self.setupScanner()
            didExitAlert()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func presentScanSuccessAlert(with address: String) {
        let alert = UIAlertController(title: "Account Added!",
                                      message: "Account with address: \(address) added successfully!",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(action)
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
        AMBUserSession.sharedInstance.createAccount(address: address) { account, _  in
            guard let account = account else {
                self.presentAccountScanFailureAlert(with: query) {
                    scanResult(false)
                }
                return
            }
            AMBUserSession.sharedInstance.storeAccount(account)
            scanResult(true)
            self.presentScanSuccessAlert(with: address)
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
