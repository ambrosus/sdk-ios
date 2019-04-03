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

public class AMBBarCodeScanManager: NSObject {

    /// Gets a type string from AVMetadataObject.type
    ///
    /// - Parameters:
    ///   - object: The AVMetadataObject with type
    /// - Returns: The string with valid type for AMBNetwork requests
    static func getSymbolyStringFromType(object: AVMetadataObject) -> String {
        switch object.type {
        case .qr:
            return "QR"
        case .dataMatrix:
            return "datamatrix"
        case .ean8:
            return "ean8"
        case .ean13:
            return "EAN13"
        case .pdf417:
            return "pdf417"
        case .aztec:
            return "aztec"
        case .code128:
            return "GTIN"
        case .code39:
            return "code39"
        case .code39Mod43:
            return "code39Mod43"
        case .code93:
            return "code93"
        case .interleaved2of5:
            return "interleaved2of5"
        case .face:
            return "face"
        case .itf14:
            return "itf14"
        default:
            return ""
        }
    }

    /// Gets a private key from QRcode
    ///
    /// - Parameters:
    ///   - code: The QRcode string
    /// - Returns: valid private key
    static func getQueryStringForAccountQr(code: String) -> String {
        let replacementStrings = ["http://", "https://"]
        let lowercasedData = code.lowercased()
        var formattedData: String = ""
        for replacementString in replacementStrings {
            formattedData = lowercasedData.replacingOccurrences(of: replacementString, with: "")
            if formattedData != lowercasedData {
                return formattedData
            }
        }
        return code
    }

    /// Gets an entity id from 1d or 2d codes
    ///
    /// - Parameters:
    ///   - code: The code string
    ///   - object: The AVMetadataObject to get type of code
    /// - Returns: valid entity id
    static func getQueryStringFromTypeAndCode(object: AVMetadataObject, code: String) -> String {
        var data = code
        let codeType: String = AMBBarCodeScanManager.getSymbolyStringFromType(object: object)
        switch object.type {
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
            return codeType + ":" + data
        case .dataMatrix:
            let mappingStrings: [String: String] = ["(01)": "[identifiers.gtin]=", "(21)": "&[identifiers.sn]=", "(10)": "&[identifiers.batch]=", "(17)": "&[identifiers.expiry]="]

            for key in mappingStrings.keys {
                if let value = mappingStrings[key] {
                    data = data.replacingOccurrences(of: key, with: value)
                }
            }
            return data
        default:
            let queryString = "[identifiers." + codeType + "]=" + data 
            return queryString
        }
    }
}
