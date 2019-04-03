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
import os.log

/// A Persistence layer to store Assets and Events for later access
@objcMembers public final class AMBDataStore: NSObject {

    /// A singleton of AMBDataSource, use to store all Assets and Events
    public static let sharedInstance = AMBDataStore()

    /// A data store for Assets, allows for inserting, fetch by id, and returning all assets
    public var assetStore = AMBAssetStore()

    /// A data store for Events, all events are associated with an Asset, and one asset maps to many Events
    public var eventStore = AMBEventStore()

    /// A data store for accounts, all accounts, can fetch an account from its public key from the store
    public var accountsStore = AMBAccountsStore()

    /// AMBNetwork.requestImage(_:) calls will return images from this cache if available
    internal let imageCache = NSCache<NSString, UIImage>()
}

/// A store for persisting assets for later access, accessible through AMBDataStore.sharedInstance.assetStore
@objcMembers public final class AMBAssetStore: NSObject {

    /// A mapping between an Asset ID (String) and an Asset
    private var assetForIdDictionary: [String: AMBAsset] = [:]

    /// Insert an asset into the store
    ///
    /// - Parameter asset: The asset to insert
    public func insert(_ asset: AMBAsset) {
        guard assetForIdDictionary[asset.id] == nil else {
            os_log("%@", log: ambLog, type: .debug, "Asset already stored")
            return
        }
        assetForIdDictionary[asset.id] = asset
    }

    /// Fetches a specific asset based on the assetId from the data store
    ///
    /// - Parameter assetId: The id for the asset to return
    /// - Returns: The asset if available in the store, nil otherwise
    public func fetch(withAssetId assetId: String) -> AMBAsset? {
        return assetForIdDictionary[assetId]
    }

    /// Get all assets saved in the asset store
    ///
    /// - Returns: The array of assets, can be empty if no assets are stored
    public var all: [AMBAsset] {
        let assets = Array(assetForIdDictionary.values)
        return sort(assets: assets)
    }

    /// Gets the assets created by a particular user
    ///
    /// - Parameter publicKey: The public key of the user who created the assets
    public func assetsForUser(withPublicKey publicKey: String) -> [AMBAsset] {
        let userAssets = Array(assetForIdDictionary.values).filter { $0.creator == publicKey }
        return sort(assets: userAssets)
    }

    /// Sorts an array of assets in reverse chronological order
    ///
    /// - Parameter assets: The assets to sort
    /// - Returns: The sorted assets
    private func sort(assets: [AMBAsset]) -> [AMBAsset] {
        let sortedAssets = assets.sorted { asset1, asset2 -> Bool in
            return asset1.timestamp > asset2.timestamp
        }
        return sortedAssets
    }

    /// Clears all assets from the store
    public func clear() {
        assetForIdDictionary.removeAll()
    }
}

/// A store for persisting events for later access, accessible through AMBDataStore.sharedInstance.eventStore
@objcMembers public final class AMBEventStore: NSObject {

    /// A mapping between an Asset ID (String) and all of its events
    private var eventsForAssetId: [String: [AMBEvent]] = [:]

    /// Insert an array of events into the store
    ///
    /// - Parameter events: The events to insert
    public func insert(_ events: [AMBEvent]) {
        guard let assetId = events.first?.assetId else {
            os_log("%@", log: ambLog, type: .debug, "Should be at least 1 event in order to store events, found zero")
            return
        }
        let sortedEvents = events.sorted { event1, event2 -> Bool in
            return event1.timestamp > event2.timestamp
        }
        eventsForAssetId[assetId] = sortedEvents
    }

    /// Clears all events from the store
    public func clear() {
        eventsForAssetId.removeAll()
    }

    /// Fetches a specific set of events based on an assetId
    ///
    /// - Parameter assetId: The id for the asset associated with these events
    /// - Returns: The events if available in the store, nil otherwise
    public func fetchEvents(forAssetId id: String) -> [AMBEvent]? {
        guard let events = eventsForAssetId[id] else {
            os_log("%@", log: ambLog, type: .info, "No events found for asset id \(id)")
            return nil
        }
        return events
    }
}

/// A store for persisting accounts for later access, accessible through AMBDataStore.sharedInstance.accountsStore
@objcMembers public final class AMBAccountsStore: NSObject {

    /// A mapping between an Asset ID (String) and all of its events
    private var accountFromPublicKey: [String: AMBAccount] = [:]

    /// Clears all accounts from the store
    public func clear() {
        accountFromPublicKey.removeAll()
    }

    /// Insert an array of events into the store
    ///
    /// - Parameter events: The events to insert
    public func add(_ account: AMBAccount) {
        guard accountFromPublicKey[account.publicKey] == nil else {
            os_log("%@", log: ambLog, type: .debug, "Account already stored")
            return
        }

        accountFromPublicKey[account.publicKey] = account
    }

    /// Fetches a specific set of events based on an assetId
    ///
    /// - Parameter assetId: The id for the asset associated with these events
    /// - Returns: The events if available in the store, nil otherwise
    public func fetchAccount(withPublicKey publicKey: String) -> AMBAccount? {
        guard let account = accountFromPublicKey[publicKey] else {
            os_log("%@", log: ambLog, type: .info, "No account found for public key \(publicKey)")
            return nil
        }
        return account
    }

    /// All accounts stored, empty if no accounts returned
    public var all: [AMBAccount] {
        var accounts = accountFromPublicKey.values.map { $0 }
        for (i, account) in accounts.enumerated() where account.publicKey == AMBUserSession.sharedInstance.signedInUserPublicKey {
                accounts.remove(at: i)
                accounts.insert(account, at: 0)
        }
        return accounts
    }
}
