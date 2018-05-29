//
//  Copyright: Ambrosus Technologies GmbH
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

/// A store for persisting assets for later access, acts as a cache for already fetched assets
public final class AMBAssetStore: NSObject {
    
    /// A mapping between an Asset ID (String) and an Asset
    private var assets: [String: AMBAsset] = [:]
    
    /// Insert an asset into the store
    ///
    /// - Parameter asset: The asset to insert
    public func insert(_ asset: AMBAsset) {
        guard assets[asset.id] == nil else {
            NSLog("Asset already stored")
            return
        }
        assets[asset.id] = asset
    }
    
    /// Fetches a specific asset based on the assetId from the data store
    ///
    /// - Parameter assetId: The id for the asset to return
    /// - Returns: The asset if available in the store, nil otherwise
    public func fetch(withAssetId assetId: String) -> AMBAsset? {
        return assets[assetId]
    }
    
    /// Get all assets saved in the asset store
    ///
    /// - Returns: The array of assets, can be empty if no assets are stored
    public func allAssets() -> [AMBAsset] {
        let sortedAssets = Array(assets.values).sorted { (asset1, asset2) -> Bool in
            return asset1.timestamp > asset2.timestamp
        }
        return sortedAssets
    }
    
}

/// A store for persisting events for later access, acts as a cache for already fetched events
public final class AMBEventStore: NSObject {
    
    /// A mapping between an Asset ID (String) and all of its events
    private var eventsForAssetId: [String: [AMBEvent]] = [:]

    /// Insert an array of events into the store
    ///
    /// - Parameter events: The events to insert
    public func insert(_ events: [AMBEvent]) {
        guard let assetId = events.first?.assetId else {
            NSLog("Should be at least 1 event in order to store events, found zero")
            return
        }
        let sortedEvents = events.sorted { (event1, event2) -> Bool in
            return event1.timestamp > event2.timestamp
        }
        eventsForAssetId[assetId] = sortedEvents
    }
    
    /// Fetches a specific set of events based on an assetId
    ///
    /// - Parameter assetId: The id for the asset associated with these events
    /// - Returns: The events if available in the store, nil otherwise
    public func fetchEvents(forAssetId assetId: String) -> [AMBEvent]? {
        guard let events = eventsForAssetId[assetId] else {
            return nil
        }
        return events
    }
    
}


/// A Persistence layer to store Assets and Events
public final class AMBDataStore: NSObject {
    
    /// A singleton of AMBDataSource, use to store all Assets and Events
    public static let sharedInstance = AMBDataStore()
    
    /// A data store for Assets, allows for inserting, fetch by id, and returning all assets
    public var assetStore = AMBAssetStore()

    /// A data store for Events, all events are associated with an Asset, and one asset maps to many Events
    public var eventStore = AMBEventStore()

    let imageCache = NSCache<NSString, UIImage>()
}
