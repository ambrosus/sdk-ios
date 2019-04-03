# Ambrosus iOS SDK's

- [AmbrosusSDK](#AmbrosusSDK)
  * [Integration](#integration)
  * [Overview](#overview)
  * [Usage](#usage)
  * [Usage (Objective-C)](#usage-objective-c)

- [AmbrosusBlockchainSDK](#AmbrosusBlockchainSDK)
  * [Features](#features)
  * [Integration](#integration-1)
  * [Overview](#overview-1)
  * [Usage](#usage-1)
  
- [Sample Application (Ambrosus Viewer)](#sample-application-ambrosus-viewer)
  * [Ambrosus Viewer Support](#ambrosus-viewer-support)
  * [Sample Symbologies](#sample-symbologies)

## AmbrosusSDK

[![Version](https://img.shields.io/cocoapods/v/AmbrosusSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusSDK)
[![License](https://img.shields.io/cocoapods/l/AmbrosusSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusSDK)
[![Platform](https://img.shields.io/cocoapods/p/AmbrosusSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusSDK)

The AmbrosusSDK for iOS makes it easy for iOS App Developers to get back data from the [Ambrosus API](https://ambrosus.docs.apiary.io) (AMB-NET), and build their own interfaces for displaying Assets and Events.

* Supports iOS 10+
* Supports Objective-C and Swift 4.2+
* Supports Xcode 10.1+

### Integration

To start using the SDK you can add the following to your Podfile:

```ruby
pod 'AmbrosusSDK'
```

You can also download or clone this repository and import the AmbrosusSDK manually if not using Cocoapods, all of the code is contained in the top level "AmbrosusSDK" folder.

### Overview

The SDK is composed of three main files all contained within the "AmbrosusSDK" folder:

`AMBNetwork.swift` 

The interface layer which makes network requests to the Ambrosus API such as fetching assets, events, and images associated with assets and Events

`AMBDataStore.swift`

A singleton caching layer, you can insert assets into it using `AMBDataStore.sharedInstance.assetStore.insert(:)` or events using `AMBDataStore.sharedInstance.eventsStore.insert(_:)`, saving assets and events in here will make them easy to fetch later, and also improve network performance when requesting already stored assets and events from `AMBNetwork`. It also will cache images downloaded using `AMBNetwork.requestImage(_:)` calls.

Models

Defines the two main data models, `AMBAsset` and `AMBEvent` these are the objects which Asset and Event details screens can be built with. To see an example of these structures being used see the AmbrosusViewer example project included with this repository.

`AMBScanViewController.swift`

Built-in scanner. There are 2 types for scanning events and assets and for scanning private keys (login)
Supports all necessary types as 1d or 2d codes (Symbologies).

### Usage

To start using the Ambrosus SDK within a Swift file first import it:
```swift
import AmbrosusSDK
```

To get back an asset from the API you can make a call like the following:

```swift
AMBNetwork.requestAsset(fromId: "0x602023f73ab25f0c95a3cf4e92c9cb2f4c9c09dbd3ca6e167d362de6e7f1eeae", completion: { (asset) in
  guard let asset = asset else {
    NSLog("asset failed to unwrap")
    return
  }
  // Use unwrapped Asset here
}
```

A single Asset in the AmbrosusSDK has many events associated with it, to get back all events associated with an asset you can make a call like the following:

```swift
AMBNetwork.requestEvents(fromAssetId: "0x602023f73ab25f0c95a3cf4e92c9cb2f4c9c09dbd3ca6e167d362de6e7f1eeae") { (events) in
    guard let events = events else {
        NSLog("Failed to return events")
        return
    }
    // Use unwrapped events here
}
```

To get back an asset along with all of its events, and store the information in the `AMBDataStore` this can be done as follows:

```swift
AMBNetwork.requestAsset(fromId: "0x602023f73ab25f0c95a3cf4e92c9cb2f4c9c09dbd3ca6e167d362de6e7f1eeae", completion: { (asset) in
    guard let asset = asset else {
        NSLog("asset failed to unwrap")
        return
    }
    AMBDataStore.sharedInstance.assetStore.insert(asset)

    AMBNetwork.requestEvents(fromAssetId: asset.id, completion: { (events) in
        guard let events = events else {
            print("events failed to unwrap")
            return
        }
        AMBDataStore.sharedInstance.eventStore.insert(events)
    })
})
```

Once the asset along with its events are stored in the `AMBDataStore` they can then be accessed like so:
```swift
let assetId = "0x602023f73ab25f0c95a3cf4e92c9cb2f4c9c09dbd3ca6e167d362de6e7f1eeae"
let asset = AMBDataStore.sharedInstance.assetStore.fetch(withAssetId: assetId)
let events = AMBDataStore.sharedInstance.eventStore.fetchEvents(forAssetId: assetId)
```

To create assets and events, you must have an Ambrosus account with the `create_entity` permission and know your public key and private key. Your private key will be used for client-side signing. Start by configuring the `AMBWeb3Manager` with your private key:

```swift
let privateKey = "[YOUR_PRIVATE_KEY]"
let publicKey = "[YOUR_PUBLIC_KEY]"
AMBWeb3Manager.sharedInstance.setAccount(withPrivateKey: privateKey)
```

Once you have your private key set you can now create assets and events using `AMBNetwork`:
```swift
AMBNetwork.createAsset(createdBy: publicKey) { (asset, error) in
    guard let assetId = asset?.id else {
        NSLog(error ?? "Error, no Asset created")
        return
    }
    let eventData = [
        ["type": "ambrosus.asset.info",
         "name": "Organic Figs (\(Int(arc4random_uniform(300))) count)",
            "assetType": "ambrosus.assetTypes.batch",
            "images": [
                "default": ["url": "http://limitlessapps.net/images/AmberAssets/figs.png"]
            ]
        ]
    ]

    AMBNetwork.createEvent(assetId: assetId, createdBy: publicKey, data: eventData) { (event, error) in
        guard let event = event else {
            NSLog(error ?? "Error, no Event created")
            return
        }

        // Do something with unwrapped event here
        print(event.description)
    }
}
```
The AmbrosusSDK has a built-in Scanner: `AMBScanViewController` 

To start scanning codes your view controller needs to use `AMBScanViewControllerDelegate`. After a code is scanned it will execute the delegate method:

```swift
func scanner(_ controller: AMBScanViewController, didCaptureCode code: String, type: String, codeResult: @escaping (Bool) -> Void) {
    // Do something with the code here
}
```
* `code` - code what you scanned.
* `type` - type of 1d or 2d code.
* `codeResult` - callback for success or erorr scan result to reload scanner if smth goes wrong.

To set up the scanner add the following to the `viewWillAppear` method:
```swift
scanner = AMBScanViewController()
scanner?.delegate = self
scanner?.setup(with: self, scannerType: .entity)
```
scannerType - has 2 states :
 1. `.entity` - for scan assets and events.
 2. `.account` - for scan private keys.
 
To remove the scanner add the following to `viewWillDisappear`:
```swift
scanner?.delegate = nil
scanner?.stop()
```

### Usage (Objective-C)

The Ambrosus SDK is also fully compatible with Objective-C, you can import the SDK by adding the following to the top of your implementation file:
```objective-c
@import AmbrosusSDK;
```

To fetch an asset as well as its events in Objective-C and store the data in `AMBDataStore` you can do the following:

```objective-c
NSString *assetId = @"0x602023f73ab25f0c95a3cf4e92c9cb2f4c9c09dbd3ca6e167d362de6e7f1eeae";
[AMBNetwork requestAssetFromId:assetId completion:^(AMBAsset * _Nullable asset) {
    if (!asset) {
        return;
    }
    [[[AMBDataStore sharedInstance] assetStore] insert:asset];

    [AMBNetwork requestEventsFromAssetId:assetId completion:^(NSArray<AMBEvent *> * _Nullable events) {
        if (!events) {
            return;
        }
        [[[AMBDataStore sharedInstance] eventStore] insert:events];
    }];
}];
```

## AmbrosusBlockchainSDK

[![Version](https://img.shields.io/cocoapods/v/AmbrosusBlockchainSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusBlockchainSDK)
[![License](https://img.shields.io/cocoapods/l/AmbrosusBlockchainSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusBlockchainSDK)
[![Platform](https://img.shields.io/cocoapods/p/AmbrosusBlockchainSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusBlockchainSDK)

The AmbrosusBlockchainSDK for iOS makes it easy for iOS App Developers to interact with the Ambrosus Blockchain from within an iOS app

* Supports iOS 11+
* Supports Objective-C and Swift 4.2+
* Supports Xcode 10.1+

### Features
* Generate Ambrosus Blockchain accounts using 12 word seed phrase, fetch address from private key, etc
* Send signed Amber token transactions using client-side signing from seed phrase.
* Fetch the Amber token balance for a user from their address

### Integration

To start using the SDK you can add the following to your Podfile:

```ruby
pod 'AmbrosusBlockchainSDK'
pod 'web3swift.pod', :git => 'https://github.com/bankex/web3swift.git', :branch => 'master', :modular_headers => true
```

You can also download or clone this repository and import the AmbrosusBlockchainSDK manually if not using Cocoapods, all of the code is contained in the top level "AmbrosusBlockchainSDK" folder.

### Overview

`AccountsGenerator.swift`

Enables the creation of a 12 word seed phrase or a private key to represent an individual account on the Blockchain.

`AmbrosusBlockchainService.swift`

Allows for communication with the Amber Blockchain. Fetch the Amber token balance for a given address, or send a signed Amber transaction from one user to another. 

### Usage

To start using the Ambrosus SDK within a Swift file first import it:

```swift
import AmbrosusBlockchainSDK
```
Now in order to create a new account, you need to use the `AccountsGenerator` to generate your 12 word seed phrase. With that you can start the `AmbrosusBlockchainService` to fetch your Amber token balance, or send signed transactions through the Blockchain.

```swift
let service = AmbrosusBlockchainService()
// Generate a new 12 word seed phrase
guard let seedPhrase = AccountsGenerator.shared.creationSeedPhraseWord else { return }

/// Start up the Blockchain Service using the new phrase to sign
/// This service by default is set to test-net so no real Amber tokens will be spent
service.start(with: seedPhrase) {
    guard let address = service.address?.address else { return }

    // Get the balance for the newly generated account
    service.fetchAmberBalance(address: address) { (balance, error) in
        guard let balance = balance else {
            print(error ?? "Unknown error occured when fetching blockchain balance")
            return
        }
        // Unwrapped balance now available
        print(balance)
    }

    let addressB = "0x70f7A7C75f0465B8B1e9a3a0398c72f91D08F89C"

    /// Send a small amount of Amber tokens to another account
    /// - Note: Unless you replace the seed phrase created at the start with one representing an account
    /// with Amber tokens, this send will not succeed since new accounts have a 0 token balance
    service.send(amount: AmberUnits.micro.rawValue, to: addressB, from: address, callback: { (success, error) in
        guard let success = success else {
            print(error ?? "Unknown error occured when sending Amber transaction")
            return
        }
        print(success)
    })
}
```

[Sample Transactions](https://explorer.ambrosus-test.com/addresses/0x70f7A7C75f0465B8B1e9a3a0398c72f91D08F89C)

## Sample Application (Ambrosus Viewer)

The included example application, Ambrosus Viewer includes a scanner that is capable of scanning 1d and 2d codes and displaying details about an associated asset and its events from AMB-NET. In App you can login with your private key and create assets and events. It comes packaged with several sample assets and events as well. The app also contains Asset Details and Event Details screens which demonstrate using the SDK to build a fully featured iOS application for viewing data stored on AMB-NET.

### Ambrosus Viewer Support

* Supports iPhone 5S and above, iPad 5th Generation and above, iPod Touch 6th Generation and Above.
* Minimum iOS Version 11
* Requires Camera permission enabled in order to scan codes
* Capable of scanning codes with the following symbologies:
  * UPCE, UPC12, EAN8, EAN13, CODE 39, CODE 128, ITF, QR, DATAMATRIX, AZTEC

### Sample Symbologies

To see details about sample assets with the Ambrosus Viewer, scan any of the following codes from the app:

|   EAN-8   |   EAN-13   |     QR     |
| --------- | ---------------------------------- | ---------- |
| &emsp;&emsp;![EAN-8 Sample](https://i.imgur.com/m7QZIaS.png)   | &emsp;&emsp;![EAN-13 Sample](https://i.imgur.com/1HXwtPr.png) | &emsp;&emsp;![QR Sample](https://i.imgur.com/JfEUGo8.png)&emsp;&emsp;
|  <a href="https://gateway-test.ambrosus.com/events?data[type]=ambrosus.asset.identifier&data[identifiers.ean8]=96385074" target="_blank">Generic Asset</a>&emsp;  | <a href="https://gateway-test.ambrosus.com/events?data[type]=ambrosus.asset.identifier&data[identifiers.ean13]=6942507312009" target="_blank">Guernsey Cow</a>&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;<a href="https://gateway-test.ambrosus.com/assets/0x4c289b68b5bb1a098a4aa622b84d6f523e02fc9346a3a0a99efdfd8a96ba56df" target="_blank">Ibuprofen Batch 200mg</a>&emsp;&emsp;

### Account Scanner Sample

![Account QR Sample](https://www.scandit.com/wp-content/themes/bridge-child/wbq_barcode_gen.php?symbology=qr&value=type%3Dambrosus.account%26account%3D0x8536eBc067457602FfC92B89B55501b54bcf5049&size=100&ec=L)

Add account (*ERC20 address:* 0x8536eBc067457602FfC92B89B55501b54bcf5049)
