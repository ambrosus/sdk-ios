## About

The Ambrosus iOS SDK makes it easy for iOS App Developers to get back data from the Ambrosus API, and build their own interfaces for displaying Assets and Events.

## Integration

To start using the SDK you can add the following to your Podfile:

```ruby
pod AmbrosusSDK
```

You can also download or clone this repository and import the AmbrosusSDK manually if not using Cocoapods, all of the code is contained in the top level "AmbrosusSDK" folder.

## Usage

The SDK is composed of 3 main files

`AMBNetwork.swift` 
The interface layer which makes network requests to the Ambrosus API such as fetching assets, events, and images associated with assets and Events

`AMBDataStore.swift`
A singleton caching layer, you can insert assets into it using `AMBDataStore.sharedInstance.assetStore.insert(:)` or events using `AMBDataStore.sharedInstance.eventsStore.insert(:)`, saving assets and events in here will make them easy to fetch later, and also improve network performance when requesting already stored assets and events from AMBNetwork. It also will cache images downloaded using `AMBNetwork.requestImage(:)` calls.

`AMBModels.swift`
Defines the two main data models, `AMBAsset` and `AMBEvent` these are the objects which Asset and Event details screens can be built with. To see an example of these structures being used see the AmbrosusViewer example project included with this repository.

To get back an asset from the API you can make a call like the following:

```swift
AMBNetwork.requestAsset(fromId: "0x74d3723909b15275791d1d0366c9627ee4c6e4f9982f31233d0dd6c054e5b664", completion: { (asset) in
  guard let asset = asset else {
    print("asset failed to unwrap")
    return
  }
  // Use unwrapped Asset here
}
```

A single Asset in the Ambrosus SDK has many events associated with it, to get back all events associated with an asset you can make a call like the following:

```swift
AMBNetwork.requestEvents(fromId: "0x74d3723909b15275791d1d0366c9627ee4c6e4f9982f31233d0dd6c054e5b664", completion: { (asset) in
  guard let asset = asset else {
    print("asset failed to unwrap")
    return
  }
  // Use unwrapped Asset here
}
```

## Supported OS & SDK Versions

* Supports iPhone 5S and above, iPad 5th Generation and above, iPod Touch 6th Generation and Above.
* Minimum iOS Version 11
* Requires Camera permission enabled in order to scan codes
* Capable of scanning codes with the following symbologies:
  * UPCE, UPC12, EAN8, EAN13, CODE 39, CODE 128, ITF, QR, DATAMATRIX

## Sample Symbologies

To see details about sample assets with the Ambrosus Viewer, scan any of the following codes from the app:

|   EAN-8   |   EAN-13   |     QR     |
| --------- | ---------------------------------- | ---------- |
| &emsp;&emsp;![EAN-8 Sample](https://i.imgur.com/m7QZIaS.png)   | &emsp;&emsp;![EAN-13 Sample](https://i.imgur.com/1HXwtPr.png) | &emsp;&emsp;![QR Sample](https://i.imgur.com/JfEUGo8.png)&emsp;&emsp;
|  <a href="https://gateway-test.ambrosus.com/events?data[type]=ambrosus.asset.identifier&data[identifiers.ean8]=96385074" target="_blank">Generic Asset</a>&emsp;  | <a href="https://gateway-test.ambrosus.com/events?data[type]=ambrosus.asset.identifier&data[identifiers.ean13]=6942507312009" target="_blank">Guernsey Cow</a>&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;<a href="https://gateway-test.ambrosus.com/assets/0x4c289b68b5bb1a098a4aa622b84d6f523e02fc9346a3a0a99efdfd8a96ba56df" target="_blank">Ibuprofen Batch 200mg</a>&emsp;&emsp;
