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
import AmbrosusSDK

final class SampleFetcher {

    let privateKey = "[YOUR_PRIVATE_KEY]"
    let publicKey = "[YOUR_PUBLIC_KEY]"

    /// Fetches sample assets and events stored as JSON locally
    func fetch() {
        requestSampleJSON()
//        AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey: privateKey)
//        requestSampleAccounts()
//        requestSampleJSON()
//        requestRealAccount()
//        web3Sample()
    }

    private func web3Sample() {
        AMBNetwork.createAsset(createdBy: publicKey) { asset, error in
            guard let asset = asset else {
                NSLog(error ?? "Error, no Asset created")
                return
            }
            let eventData = [
                ["type": "ambrosus.asset.info",
                 "name": "Organic Figs New (\(Int(arc4random_uniform(10000))) count)",
                    "assetType": "ambrosus.assetTypes.batch",
                    "images": [
                        "default": ["url": "http://limitlessapps.net/images/AmberAssets/figs.png"]
                    ]
                ]
            ]
            let eventData1 = [
                ["type": "ambrosus",
                 "name": "FigsSSSSSSSS (\(Int(arc4random_uniform(10000))) count)",
                    "assetType": "ambrosus.assetTypes.figs",
                    "images": [
                        "default": ["url": "http://limitlessapps.net/images/AmberAssets/figs.png"]
                    ]
                ]
            ]
            let eventData2 = [
                ["type": "ambrosus",
                 "name": "Figs Of New (\(Int(arc4random_uniform(10000))) count)",
                    "assetType": "ambrosus.assetTypes.figs",
                    "images": [
                        "default": ["url": "http://limitlessapps.net/images/AmberAssets/figs.png"]
                    ]
                ]
            ]
            AMBDataStore.sharedInstance.assetStore.insert(asset)
            AMBNetwork.createEvent(assetId: asset.id, createdBy: self.publicKey, accessLevel: 1, data: eventData) { event, error in
                guard let event = event else {
                    NSLog(error ?? "Error, no Event created")
                    return
                }
                AMBNetwork.createEvent(assetId: asset.id, createdBy: self.publicKey, accessLevel: 1, data: eventData2) { event1, error in
                    guard let event1 = event1 else {
                        NSLog(error ?? "Error, no Event created")
                        return
                    }
                    AMBNetwork.createEvent(assetId: asset.id, createdBy: self.publicKey, accessLevel: 0, data: eventData1) { event2, error in
                        guard let event2 = event2 else {
                            NSLog(error ?? "Error, no Event created")
                            return
                        }
                        AMBDataStore.sharedInstance.eventStore.insert([event2, event1, event])
                        // Do something with unwrapped event here
                    }
                    // Do something with unwrapped event here
                }
                // Do something with unwrapped event here
                print(event.description)
            }
        }
    }

    private func requestRealAccount() {
        if let token = UserDefaults.standard.string(forKey: Interface.tokenKey) {
            AMBNetwork.setAuthorizationToken(with: token)
        } else {
            AMBNetwork.createToken(createdBy: publicKey, timestamp: 1540000002) { token, error in
                guard let token = token else {
                    print(error ?? "unable to generate token")
                    return
                }
                UserDefaults.standard.set(token, forKey: Interface.tokenKey)
            }
        }
        createAndStoreAccount(with: "0x085b2880f2A8f1bd04930aED3eD8FA21a8DCc090")
    }

    private func createAndStoreAccount(with address: String) {
        AMBUserSession.sharedInstance.createAccount(address: address, canRegisterAccounts: true) { account, _ in
            guard let account = account else {
                return
            }

            AMBUserSession.sharedInstance.storeAccount(account)
        }
    }

    func requestSampleAccounts() {
        SampleFetcher.setSampleAccounts()
    }

    static func setSampleAccounts() {
        AMBDataStore.sharedInstance.accountsStore.clear()
        let sampleImages: [UIImage] = UserDefaults.standard.bool(forKey: Settings.accessLevelDemoActivatedKey) ?
        [
            #imageLiteral(resourceName: "PharmacyAccount"),
            #imageLiteral(resourceName: "ManufacturerAccount")
        ] :
        [
            #imageLiteral(resourceName: "FarmerAccount"),
            #imageLiteral(resourceName: "PharmacyAccount"),
            #imageLiteral(resourceName: "RetailerAccount"),
            #imageLiteral(resourceName: "AccountsSample3"),
            #imageLiteral(resourceName: "AccountsSample5")
        ]

        let sampleAccounts =
            UserDefaults.standard.bool(forKey: Settings.accessLevelDemoActivatedKey) ?
                [
                    AMBAccount(publicKey: "0x100", privateKey: "0x100", name: "Pharmacist", image: sampleImages[0], accessLevel: 1),
                    AMBAccount(publicKey: "0x10002", privateKey: "0x10002", name: "Manufacturer", image: sampleImages[1], accessLevel: 2)
                ] :
                [
                    AMBAccount(publicKey: "0xFE8F7769e12b565319eD60AD53C087F5353E4406", privateKey: "0xc2c34bb72c8d0131bbb1eef56be0888938616dba92da7e5d434d3f0bb5745668", name: "Farmer", image: sampleImages[0]),
                    AMBAccount(publicKey: "0x9A3Db936c94523ceb1CcC6C90461bc34a46E9dfE", privateKey: "0xc4a39bb72c8d0c31ebb1eef56be0888932f16dca92da7e5d434d3f0bb5749276", name: "Pharmacist", image: sampleImages[1])
        ]

        for account in sampleAccounts {
            AMBUserSession.sharedInstance.storeAccount(account)
        }
    }

    private func requestSampleJSON() {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        for path in paths {
            if path.contains("Asset") {
                requestAsset(from: path)
            } else if path.contains("Events") {
                requestEvent(from: path)
            }
        }
    }

    private func requestAsset(from path: String) {
        if let assetDictionary = requestJSON(path: path) as? [String: Any],
            let asset = AMBAsset(json: assetDictionary) {
            AMBDataStore.sharedInstance.assetStore.insert(asset)
        }
    }

    private func requestEvent(from path: String) {
        guard let eventDictionaries = requestJSON(path: path) as? [String: Any],
            let eventPairs = eventDictionaries["results"] as? [[String: Any]] else {
                return
        }
        let events = eventPairs.compactMap { AMBEvent(json: $0) }
        AMBDataStore.sharedInstance.eventStore.insert(events)
    }

    private func requestJSON(path: String) -> Any? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return jsonResult
        } catch {
            return nil
        }
    }
}
