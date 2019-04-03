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

final class AssetScanViewController: UIViewController {

    fileprivate let didShowInstructionsKey = "didShowInstructions"
    fileprivate var scanner: AMBScanViewController?
    fileprivate var authorizationDialog: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.centerItems()
        let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "information"), style: .plain, target: self, action: #selector(tappedHelp))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = leftBarButtonItem

        let rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Profile"), style: .plain, target: self, action: #selector(tappedAccounts))
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButtonItem
        showInstructionsOnFirstLaunch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.topItem?.title = "Scan".localized
        setupScanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeScanner()
    }

    @objc func tappedHelp() {
        displayInstructions()
    }

    @objc func tappedAccounts() {
        displayAccounts()
    }

    func setupScanner() {
        scanner = AMBScanViewController()
        scanner?.delegate = self
        scanner?.setup(with: self, scannerType: .entity)
    }

    func removeScanner() {
        scanner?.delegate = nil
        scanner?.stop()
    }

    private func displayAccounts() {
        if !AccountsManager.sharedInstance.isSignedIn() {
            authorizationDialog = DialogBuilder(style: .alert)
                .setTitle("Enter your private key".localized)
                .setMessage("If you don't provide your private key , your will be in guest mode".localized)
                .addAction("OK".localized, completion: { _ in
                    self.enterPrivateKey()
                })
                .addAction("Cancel".localized, completion: nil)
                .withField(placeholder: "your private key".localized)
                .build()
            DispatchQueue.main.async {
                self.present(self.authorizationDialog, animated: true, completion: nil)
            }
        } else {
            authorizationDialog = DialogBuilder(style: .alert)
                .setTitle("You already login".localized)
                .setMessage("You already sing in if you would like to sign out you can do this in settings tab.".localized)
                .addAction("OK".localized, completion: nil)
                .build()
            DispatchQueue.main.async {
                self.present(self.authorizationDialog, animated: true, completion: nil)
            }
        }
    }

    func enterPrivateKey() {
        AccountsManager.sharedInstance.signIn(with: authorizationDialog?.textFields?.first?.text ?? "")
        if !AccountsManager.sharedInstance.isSignedIn() {
            let alert = DialogBuilder(style: .alert)
                .setTitle("Error".localized)
                .setMessage("Invalid private key.".localized)
                .addAction("OK".localized, completion: nil)
                .build()
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func displayInstructions() {
        UserDefaults.standard.set(true, forKey: didShowInstructionsKey)
        let samplesURLString = "https://github.com/ambrosus/sdk-ios"
        let presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        let alert = DialogBuilder(style: .alert)
            .setTitle("Instructions".localized)
            .setMessage(String(format: "InstructionsKey".localized, samplesURLString))
            .addAction("Copy URL".localized, completion: { _ in
                UIPasteboard.general.string = samplesURLString
                let alert = DialogBuilder(style: .alert)
                    .setTitle("Copied".localized)
                    .setMessage(String(format: "SampleCodesUrlKey".localized, samplesURLString))
                    .addAction("", completion: nil)
                    .build()
                presentingViewController?.present(alert, animated: true, completion: nil)
            })
            .addAction("Close".localized, completion: nil)
            .build()
        presentingViewController?.present(alert, animated: true, completion: nil)
    }

    /// If the user has never seen the instructions before display them
    private func showInstructionsOnFirstLaunch() {
        let didShowInstructionsOnFirstLaunch = UserDefaults.standard.bool(forKey: didShowInstructionsKey)
        if !didShowInstructionsOnFirstLaunch {
            displayInstructions()
        }
    }
}

extension AssetScanViewController {

    private func presentAssetScanFailureAlert(with query: String, codeType: String, didExitAlert: @escaping () -> Void) {
        let alert = DialogBuilder(style: .alert)
            .setTitle(String(format: "ScannedCodeKey".localized, codeType))
            .setMessage("Failed to find Ambrosus Asset from request with query: ".localized + query)
            .addAction("OK".localized, completion: { _ in
                didExitAlert()
            })
            .build()
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func presentAssetViewController(with asset: AMBAsset) {
        guard let assetDetailCollectionViewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: AssetDetailCollectionViewController.self)) as? AssetDetailCollectionViewController else {
            return
        }

        DispatchQueue.main.async {
            assetDetailCollectionViewController.asset = asset
            self.navigationController?.pushViewController(assetDetailCollectionViewController, animated: true)
        }
    }

    private func performAssetScan(with query: String, codeType: String, codeResult: @escaping (Bool) -> Void) {
        // If there is no symbology string the query is an id
        if codeType == "QR" {
            AMBNetwork.requestAsset(fromId: query, completion: { asset, _ in
                guard let asset = asset else {
                    self.presentAssetScanFailureAlert(with: query, codeType: codeType) {
                        codeResult(false)
                    }
                    return
                }
                AMBDataStore.sharedInstance.assetStore.insert(asset)
                codeResult(true)
                self.presentAssetViewController(with: asset)
                return
            })
        } else {
            AMBNetwork.requestEvents(fromQuery: query, completion: { events, _  in
                guard let events = events,
                    let assetId = events.first?.assetId else {
                        self.presentAssetScanFailureAlert(with: query, codeType: codeType) {
                            codeResult(false)
                        }
                        return
                }
                AMBDataStore.sharedInstance.eventStore.insert(events)
                AMBNetwork.requestAsset(fromId: assetId, completion: { asset, _ in

                    guard let asset = asset else {
                        self.presentAssetScanFailureAlert(with: query, codeType: codeType) {
                            codeResult(false)
                        }
                        return
                    }
                    AMBDataStore.sharedInstance.assetStore.insert(asset)
                    codeResult(true)
                    self.presentAssetViewController(with: asset)
                    return
                })
            })
        }
    }
}

extension AssetScanViewController: AMBScanViewControllerDelegate {
    func scanner(_ controller: AMBScanViewController, didCaptureCode code: String, type: String, codeResult: @escaping (Bool) -> Void) {
        performAssetScan(with: code, codeType: type) { result in
            codeResult(result)
        }
    }
}
