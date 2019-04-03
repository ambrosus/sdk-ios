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

class CoffeeScanerViewController: UIViewController {

    fileprivate var scanner: AMBScanViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.topItem?.title = "Scan"
        setupScanner()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeScanner()
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
}

extension CoffeeScanerViewController: AMBScanViewControllerDelegate {
    func scanner(_ controller: AMBScanViewController, didCaptureCode code: String, type: String, codeResult: @escaping (Bool) -> Void) {
        let alert = DialogBuilder(style: .alert)
                    .setTitle("Scanned \(type) code")
                    .setMessage(code)
                    .addAction("OK", completion: { _ in
                        self.removeScanner()
                        self.setupScanner()
                    })
                    .build()
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
