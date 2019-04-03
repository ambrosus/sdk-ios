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

    public static let sharedInstance = SampleFetcher()

    var privateKey = String()
    var publicKey = String()

    private let sampleAccounts = [
        AMBAccount(publicKey: "0x9A3Db936c94523ceb1CcC6C90461bc34a46E9dfE", privateKey: "0xc104ec10ff80d8011b972470fe2e60fa968149a16c61a42b4d15067c29ff4e4c", name: "public account", image: #imageLiteral(resourceName: "FarmerAccount")),
        AMBAccount(publicKey: "0x446D213e730658199dbCA28D26562C1b8746F9e0", privateKey: "0x3e2711db637d1f0b6c12ae11ffc8a47f8bb59e5c0bc6dd0af4d536448bc6d048", name: "account with access level 1", image: #imageLiteral(resourceName: "PharmacyAccount")),
        AMBAccount(publicKey: "0xFE8F7769e12b565319eD60AD53C087F5353E4406", privateKey: "0xc2c34bb72c8d0131bbb1eef56be0888938616dba92da7e5d434d3f0bb5745668", name: "account with access level 2", image: #imageLiteral(resourceName: "RetailerAccount"))]

    /// Fetches sample assets and events stored as JSON locally
    func fetch() {
        AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey: privateKey)
        requestSampleAccounts()
        requestSampleJSON()
    }

    private func requestCreationAssetsAndEventsForSpecificAccessLevels() {
        self.setAccountKey(with: self.sampleAccounts[0])
        self.createAssetsForSpecificAccessProfiles {
            self.setAccountKey(with: self.sampleAccounts[1])
            self.createAssetsForSpecificAccessProfiles {
                self.setAccountKey(with: self.sampleAccounts[2])
                self.createAssetsForSpecificAccessProfiles {
                    self.signOut()
                }
            }
        }
    }

    private func createAssetsForSpecificAccessProfiles(completion : @escaping () -> Void) {
        self.createAssetWithPublicAccess(completion: {
            self.createAssetWithPrivateEventAccess1(completion: {
                self.createAssetWithPrivateEventAccess2(completion: {
                    completion()
                })
            })
        })
    }

    private func createAssetWithPrivateEventAccess2(completion : @escaping () -> Void) {
        AMBNetwork.createAsset(createdBy: publicKey) { asset, error in
            guard let asset = asset else {
                NSLog(error ?? "Error, no Asset created")
                completion()
                return
            }
            let eventData = [
                ["type": "ambrosus.asset.test",
                 "name": "TEST (ACCESS LEVEL 2)",
                 "assetType": "ambrosus.assetTypes"]
            ]
            AMBDataStore.sharedInstance.assetStore.insert(asset)
            AMBNetwork.createEvent(assetId: asset.id, createdBy: self.publicKey, accessLevel: 2, data: eventData) { event, error in
                guard let event = event else {
                    NSLog(error ?? "Error, no Event created")
                    completion()
                    return
                }
                AMBDataStore.sharedInstance.eventStore.insert([event])
                print(event.description)
                completion()
            }
        }
    }

    private func createAssetWithPrivateEventAccess1(completion : @escaping () -> Void) {
        AMBNetwork.createAsset(createdBy: publicKey) { asset, error in
            guard let asset = asset else {
                NSLog(error ?? "Error, no Asset created")
                completion()
                return
            }
            let eventData = [
                ["type": "ambrosus.asset.info",
                 "name": "TEST (ACCESS LEVEL 1)",
                 "assetType": "ambrosus.assetTypes.batch"
                ]
            ]
            AMBDataStore.sharedInstance.assetStore.insert(asset)
            AMBNetwork.createEvent(assetId: asset.id, createdBy: self.publicKey, accessLevel: 1, data: eventData) { event, error in
                guard let event = event else {
                    NSLog(error ?? "Error, no Event created")
                    completion()
                    return
                }
                AMBDataStore.sharedInstance.eventStore.insert([event])
                print(event.description)
                completion()
            }
        }
    }

    private func createAssetWithPublicAccess(completion : @escaping () -> Void) {
        AMBNetwork.createAsset(createdBy: publicKey) { asset, error in
            guard let asset = asset else {
                NSLog(error ?? "Error, no Asset created")
                completion()
                return
            }
            let eventData = [
                ["type": "ambrosus.asset.info",
                 "name": "TEST (ACCESS LEVEL 0)",
                 "assetType": "ambrosus.assetTypes.batch",
                 "images": [
                    "default": ["url": "http://limitlessapps.net/images/AmberAssets/figs.png"]
                    ]
                ]
            ]
            AMBDataStore.sharedInstance.assetStore.insert(asset)
            AMBNetwork.createEvent(assetId: asset.id, createdBy: self.publicKey, accessLevel: 0, data: eventData) { event, error in
                guard let event = event else {
                    NSLog(error ?? "Error, no Event created")
                    completion()
                    return
                }
                AMBDataStore.sharedInstance.eventStore.insert([event])
                print(event.description)
                completion()
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
        for account in  SampleFetcher.sharedInstance.sampleAccounts {
            AMBUserSession.sharedInstance.storeAccount(account)
        }
    }

    func setAccountKey(with account: AMBAccount) {
        publicKey = account.publicKey
        AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey: privateKey)
    }

    func signOut() {
        privateKey = String()
        publicKey = String()
        AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey: privateKey)
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
