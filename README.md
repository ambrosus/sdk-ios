# Ambrosus iOS SDK

The Ambrosus iOS SDK makes it easy for iOS App Developers to get back data from the [Ambrosus API](https://ambrosus.docs.apiary.io) (AMB-NET), and build their own interfaces for displaying Assets and Events.

* [Integration](#integration)
* [Overview](#overview)
* [Usage](#usage)

## Integration

To start using the SDK you can add the following to your Podfile:

```ruby
pod AmbrosusSDK
```

You can also download or clone this repository and import the AmbrosusSDK manually if not using Cocoapods, all of the code is contained in the top level "AmbrosusSDK" folder.

## Overview

The SDK is composed of three main files all contained within the "AmbrosusSDK" folder:

`AMBNetwork.swift` 

The interface layer which makes network requests to the Ambrosus API such as fetching assets, events, and images associated with assets and Events

`AMBDataStore.swift`

A singleton caching layer, you can insert assets into it using `AMBDataStore.sharedInstance.assetStore.insert(:)` or events using `AMBDataStore.sharedInstance.eventsStore.insert(:)`, saving assets and events in here will make them easy to fetch later, and also improve network performance when requesting already stored assets and events from AMBNetwork. It also will cache images downloaded using `AMBNetwork.requestImage(:)` calls.

`AMBModels.swift`

Defines the two main data models, `AMBAsset` and `AMBEvent` these are the objects which Asset and Event details screens can be built with. To see an example of these structures being used see the AmbrosusViewer example project included with this repository.

## Usage

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
AMBNetwork.requestEvents(fromAssetId: "0x74d3723909b15275791d1d0366c9627ee4c6e4f9982f31233d0dd6c054e5b664") { (events) in
    guard let events = events else {
        print("Failed to return events")
        return
    }
    // Use unwrapped events here
}
```

To get back an asset along with all of its events, and store the information in the `AMBDataStore` this can be done as follows:

```swift
AMBNetwork.requestAsset(fromId: "0x74d3723909b15275791d1d0366c9627ee4c6e4f9982f31233d0dd6c054e5b664", completion: { (asset) in
    guard let asset = asset else {
        print("asset failed to unwrap")
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
let assetId = "0x74d3723909b15275791d1d0366c9627ee4c6e4f9982f31233d0dd6c054e5b664"
let asset = AMBDataStore.sharedInstance.assetStore.fetch(withAssetId: assetId)
let events = AMBDataStore.sharedInstance.eventStore.fetchEvents(forAssetId: assetId)
```

# Sample Application (Ambrosus Viewer)

The included example application, Ambrosus Viewer includes a scanner that is capable of scanning 1d and 2d codes and displaying details about an associated asset and its events from AMB-NET. It comes packaged with several sample assets and events as well. The app also contains Asset Details and Event Details screens which demonstrate using the SDK to build a fully featured iOS application for viewing data stored on AMB-NET.

To use the scanner in the Ambrosus Viewer you need a [Scandit](https://scandit.com) API key, you can sign up for a 30 day trial here:
https://ssl.scandit.com/customers/new?p=test  

## Ambrosus Viewer Support

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
