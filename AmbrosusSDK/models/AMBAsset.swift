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

@objcMembers public class AMBAsset: NSObject {

    /// The content of this asset
    public let content: AMBAssetContent

    /// The metadata of this asset
    public let metadata: AMBMetadata?

    /// A signature unique to this asset, used to verify authenticity
    public let signature: String

    /// A formatted date converted from the creation timestamp (e.g. Sep 17, 2017)
    public let date: String

    /// The address of the creator of this asset
    public let creator: String

    /// The unique identifier associated with only this asset, used to map an asset to its associated Events
    public let id: String

    /// A timestamp in seconds of when this asset was created
    public let timestamp: Double

    /// An array of sections, useful for displaying details about this asset in a table or collection view
    public let formattedSections: AMBFormattedSections

    public init?(json: [String: Any]?) {
        guard let json = json,
            let id = json[AMBConstants.assetIdKey] as? String,
            let contentJson = json[AMBConstants.contentKey] as? [String: Any],
            let content = AMBAssetContent(json: contentJson) else {
                return nil
        }
        self.id = id
        self.content = content
        self.signature = self.content.signature
        self.date = AMBDateFetcher.getDate(fromTimestamp: self.content.idData.timestamp)
        self.creator = self.content.idData.createdBy
        self.timestamp = self.content.idData.timestamp
        self.formattedSections = AMBSectionFormatter.getFormattedSections(fromData: json)
        let metadataDict = json[AMBConstants.metadataKey] as? [String: Any]
        self.metadata = AMBMetadata(json: metadataDict)
        super.init()
    }

    public override init() {
        self.signature = ""
        self.date = ""
        self.creator = ""
        self.id = ""
        self.timestamp = 0
        self.formattedSections = []
        self.content = AMBAssetContent()
        self.metadata = AMBMetadata()
        super.init()
    }

    // An Array of events for this asset
    public var events: [AMBEvent]? {
        return AMBDataStore.sharedInstance.eventStore.fetchEvents(forAssetId: id)
    }

    // Information about asset
    fileprivate var assetInfo: AMBAssetInfo? {
        return events?.first { $0.assetInfo != nil }?.assetInfo
    }

    /// A descriptive name of the asset, optional. Can fall back to using id if name is unavailable
    public var name: String? {
        return assetInfo?.name
    }

    /// Finds an image if one is available for the asset
    public var imageURLString: String? {
        return assetInfo?.imagePath
    }

}
