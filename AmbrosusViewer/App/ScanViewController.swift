//
//  Copyright: Ambrosus Technologies GmbH
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

final class ScanDataFormatter {

    func getFormattedString(for code: SBSCode) -> String {
        var data = code.data ?? ""
        switch code.symbology {
        case .qr:
            let baseURL = "amb.to"
            let replacementStrings = ["http://" + baseURL + "/",
                                      "https://" + baseURL + "/"]

            let lowercasedData = data.lowercased()
            var formattedData: String = ""
            for replacementString in replacementStrings {
                formattedData = lowercasedData.replacingOccurrences(of: replacementString, with: "")

                // Make sure the strings "http://amb.to/" or "https://amb.to/" were found to send back the ambrosus id
                if formattedData != lowercasedData {
                    return formattedData
                }
            }
            return code.symbologyString + ":" + data
        case .datamatrix:
            let mappingStrings: [String: String] = ["(01)": "[identifiers.gtin]=", "(21)": "&[identifiers.sn]=", "(10)": "&[identifiers.batch]=", "(17)": "&[identifiers.expiry]="]

            for key in mappingStrings.keys {
                if let value = mappingStrings[key] {
                    data = data.replacingOccurrences(of: key, with: value)
                }
            }
            return data
        default:
            let queryString = "[identifiers." + code.symbologyString.lowercased() + "]=" + data
            return queryString
        }
    }
}

final class ScanViewController: UIViewController {
    
    fileprivate let didShowInstructionsKey = "didShowInstructions"
    
    private lazy var barcodePicker: SBSBarcodePicker = {
        let settings = SBSScanSettings.default()
        
        let symbologies: Set<SBSSymbology> = [.upce, .upc12, .ean8, .ean13, .code39, .code128, .itf, .qr, .datamatrix]
        for symbology in symbologies {
            settings.setSymbology(symbology, enabled: true)
        }
        
        // Create the barcode picker with the settings just created
        let barcodePicker = SBSBarcodePicker(settings:settings)
        return barcodePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tabBarController?.tabBar.centerItems()
        let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "information"), style: .plain, target: self, action: #selector(tappedHelp))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = leftBarButtonItem
        setupScanner()
        showInstructionsOnFirstLaunch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.topItem?.title = "Scan"
        barcodePicker.resumeScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barcodePicker.pauseScanning()
    }
    
    @objc func tappedHelp() {
        displayInstructions()
    }
    
    private func displayInstructions() {
        UserDefaults.standard.set(true, forKey: didShowInstructionsKey)

        let presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        let samplesURLString = "https://github.com/ambrosus/sdk-ios"
        let alert = UIAlertController(title: "Instructions",
                                      message: """
            Ambrosus Viewer is capable of scanning Bar Codes, QR Codes, and Datamatrix codes. Codes with Ambrosus identifiers will display details about an asset on the AMB-Net.
            
            For a set of sample of codes you can scan visit:
            
            \(samplesURLString)
            
            We recommend opening this link on a separate computer so you can scan codes with this device.
            
            To see samples already included with the app select the browse tab (folder icon in the bottom right).
            """,
            preferredStyle: .alert)
        
        let actionCopy = UIAlertAction(title: "Copy URL", style: .default) { _ in
            UIPasteboard.general.string = samplesURLString
            let alert = UIAlertController(title: "Copied",
                                          message: """
                URL to website with sample codes to scan:
                \(samplesURLString)
                was copied successfully!
                """,
                preferredStyle: .alert)
            let actionClose = UIAlertAction(title: "Close", style: .cancel) { _ in
            }
            alert.addAction(actionClose)
            presentingViewController?.present(alert, animated: true, completion: nil)
        }
        
        let actionClose = UIAlertAction(title: "Close", style: .cancel) { _ in
        }
        
        alert.addAction(actionCopy)
        alert.addAction(actionClose)
        presentingViewController?.present(alert, animated: true, completion: nil)
    }
    
    /// If the user has never seen the instructions before display them
    private func showInstructionsOnFirstLaunch() {
        let didShowInstructionsOnFirstLaunch = UserDefaults.standard.bool(forKey: didShowInstructionsKey)
        if !didShowInstructionsOnFirstLaunch {
            displayInstructions()
        }
    }

    private func setupScanner() {
        // Add the barcode picker as a child view controller
        addChild(barcodePicker)
        view.addSubview(barcodePicker.view)
        barcodePicker.didMove(toParent: self)

        // Set the allowed interface orientations. The value UIInterfaceOrientationMaskAll is the
        // default and is only shown here for completeness.
        barcodePicker.allowedInterfaceOrientations = .all
        // Set the delegate to receive scan event callbacks
        barcodePicker.scanDelegate = self
        barcodePicker.startScanning()
    }

    private func presentAssetViewController(with asset: AMBAsset) {
        guard let assetDetailCollectionViewController = Interface.mainStoryboard.instantiateViewController(withIdentifier: String(describing: AssetDetailCollectionViewController.self)) as? AssetDetailCollectionViewController else {
            return
        }

        assetDetailCollectionViewController.asset = asset
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(assetDetailCollectionViewController, animated: true)
        }
    }

}

extension ScanViewController: SBSScanDelegate {
    // This delegate method of the SBSScanDelegate protocol needs to be implemented by
    // every app that uses the Scandit Barcode Scanner and this is where the custom application logic
    // goes. In the example below, we are just showing an alert view with the result.
    func barcodePicker(_ picker: SBSBarcodePicker, didScan session: SBSScanSession) {
        // Call pauseScanning on the session (and on the session queue) to immediately pause scanning
        // and close the camera. This is the preferred way to pause scanning barcodes from the
        // SBSScanDelegate as it is made sure that no new codes are scanned.
        // When calling pauseScanning on the picker, another code may be scanned before pauseScanning
        // has completely paused the scanning process.
        session.pauseScanning()

        let code = session.newlyRecognizedCodes[0]
        // The barcodePicker(_:didScan:) delegate method is invoked from a picker-internal queue. To
        // display the results in the UI, you need to dispatch to the main queue. Note that it's not
        // allowed to use SBSScanSession in the dispatched block as it's only allowed to access the
        // SBSScanSession inside the barcodePicker(_:didScan:) callback. It is however safe to
        // use results returned by session.newlyRecognizedCodes etc.
        DispatchQueue.main.async {
            self.performAssetScan(with: picker, session: session, code: code)
        }
    }
    
    private func presentAssetScanFailureAlert(with picker: SBSBarcodePicker, code: SBSCode, query: String) {
        let alert = UIAlertController(title: "Scanned \(code.symbologyString) code",
            message: "Failed to find Ambrosus Asset from request with query: " + query,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            picker.resumeScanning()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func performAssetScan(with picker: SBSBarcodePicker, session: SBSScanSession, code: SBSCode) {
        let data = code.data ?? ""
        let scanDataFormatter = ScanDataFormatter()
        let query = scanDataFormatter.getFormattedString(for: code)
        guard !data.isEmpty else {
            presentAssetScanFailureAlert(with: picker, code: code, query: query)
            return
        }

        // If there is no symbology string the query is an id
        if code.symbology == .qr && !query.contains(code.symbologyString) {

            AMBNetwork.requestAsset(fromId: query, completion: { (asset) in
                guard let asset = asset else {
                    self.presentAssetScanFailureAlert(with: picker, code: code, query: query)
                    return
                }
                AMBDataStore.sharedInstance.assetStore.insert(asset)
                self.presentAssetViewController(with: asset)
                return
            })
        } else {
            AMBNetwork.requestEvents(fromQuery: query, completion: { (events) in
                guard let events = events,
                    let assetId = events.first?.assetId else {
                        self.presentAssetScanFailureAlert(with: picker, code: code, query: query)
                        return
                }
                AMBDataStore.sharedInstance.eventStore.insert(events)
                AMBNetwork.requestAsset(fromId: assetId, completion: { (asset) in
                    guard let asset = asset else {
                        self.presentAssetScanFailureAlert(with: picker, code: code, query: query)
                        return
                    }
                    AMBDataStore.sharedInstance.assetStore.insert(asset)
                    self.presentAssetViewController(with: asset)
                    return
                })
            })
        }
    }
}
