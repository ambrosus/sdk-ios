#
# Be sure to run `pod lib lint AmbrosusBlockchainSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AmbrosusBlockchainSDK'
  s.version          = '1.0.0'
  s.summary          = 'Makes it easy for iOS App Developers to build apps that are powered by the Ambrosus Blockchain.'
  s.swift_version    = '4.2'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
# AmbrosusBlockchainSDK

[![Version](https://img.shields.io/cocoapods/v/AmbrosusBlockchainSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusBlockchainSDK)
[![License](https://img.shields.io/cocoapods/l/AmbrosusBlockchainSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusBlockchainSDK)
[![Platform](https://img.shields.io/cocoapods/p/AmbrosusBlockchainSDK.svg?style=flat)](http://cocoapods.org/pods/AmbrosusBlockchainSDK)

* [Features](#features)
* [Integration](#integration-1)
* [Overview](#overview-1)
* [Usage](#usage-1)

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
                       DESC

  s.homepage         = 'https://github.com/ambrosus/sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ambrosus' => 'tech@ambrosus.com' }
  s.source           = { :git => 'https://github.com/ambrosus/sdk-ios.git', :tag => 'AmbrosusBlockchain-'+s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'AmbrosusBlockchainSDK/**/*'
  
  # s.resource_bundles = {
  #   'AmbrosusBlockchainSDK' => ['AmbrosusBlockchainSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency  'web3swift.pod'
end
