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
import AVFoundation

public enum ScannerType {
    case account
    case entity
}

public protocol AMBScanViewControllerDelegate: class {
    func scanner(
        _ controller: AMBScanViewController,
        didCaptureCode code: String,
        type: String,
        codeResult: @escaping (Bool) -> Void
    )
}

@objcMembers public class AMBScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    public weak var delegate: AMBScanViewControllerDelegate?
    public var currentScannerType: ScannerType?

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        guard let captureSession = captureSession else {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        setupMetadata()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func setupMetadata() {
        guard let captureSession = captureSession else {
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            switch currentScannerType {
            case .account?:
                metadataOutput.metadataObjectTypes = [.qr]
            case .entity?:
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .aztec, .qr, .dataMatrix, .code128, .code39, .code39Mod43, .code93, .interleaved2of5, .face, .itf14, .upce]
            case .none:
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .aztec, .qr, .dataMatrix, .code128, .code39, .code39Mod43, .code93, .interleaved2of5, .face, .itf14, .upce]
            }
        } else {
            failed()
            return
        }
    }

   func failed() {
        let alertController = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
        captureSession = nil
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else {
                return
        }
        captureSession?.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        switch currentScannerType {
        case .account?:
            found(code: AMBBarCodeScanManager.getQueryStringForAccountQr(code: stringValue), type: AMBBarCodeScanManager.getSymbolyStringFromType(object: metadataObject))
        case .entity?:
            let id: String = AMBBarCodeScanManager.getQueryStringFromTypeAndCode(object: metadataObject, code: stringValue)
            found(code: id, type: AMBBarCodeScanManager.getSymbolyStringFromType(object: metadataObject))
        case .none:
            break
        }
    }

    public func setup(with vc: UIViewController, scannerType: ScannerType) {
        currentScannerType = scannerType
        vc.addChild(self)
        vc.view.addSubview(self.view)
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }

    public func stop() {
        self.removeFromParent()
        DispatchQueue.main.async {
            self.view.removeFromSuperview()
        }
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    public func found(code: String, type: String) {
        print(code)
        delegate?.scanner(self, didCaptureCode: code, type: type) { success in
            if !success && self.captureSession?.isRunning == false {
                self.captureSession?.startRunning()
            }
        }
    }

    override public var prefersStatusBarHidden: Bool {
        return true
    }
}
