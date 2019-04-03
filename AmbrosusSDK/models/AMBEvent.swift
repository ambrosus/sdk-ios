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

@objcMembers public class AMBEvent: NSObject {

    /// A signature unique to this event, used to verify authenticity
    public let signature: String

    /// A formatted date converted from the creation timestamp (e.g. Sep 17, 2017)
    public let date: String

    /// The address of the creator of this event
    public let creator: String

    /// The unique identifier associated with only this event
    public let id: String

    /// The unique identifier for the asset this event happened to
    public let assetId: String

    /// A descriptive name of the event, optional. Fall back to using type if name isn't available
    public let name: String?

    /// The type describes the category of event that occurs, can be used as a name for the event as well
    public let type: String?

    /// A timestamp in seconds of when this event was created
    public let timestamp: Double

    /// Determines who has access to view this event, 0 = public. The higher the level the more restricted the event is
    public let accessLevel: Int

    /// Formatted data sections, useful for displaying details about this instance in a table or collection view
    public let formattedSections: AMBFormattedSections

    /// Contains asset info such as name and image
    public let assetInfo: AMBAssetInfo?

    /// Contains longitude,lattitude and name of the event location
    public let location: AMBLocationModel?

    /// Contains content with data, signature and idData model
    public let content: AMBEventContent

    /// Contains metadata for this event
    public let metadata: AMBMetadata?

    public override init() {
        self.signature = ""
        self.date = ""
        self.creator = ""
        self.id = ""
        self.assetId = ""
        self.type = ""
        self.name = ""
        self.timestamp = 0
        self.accessLevel = 0
        self.formattedSections = []
        self.assetInfo = nil
        self.location = AMBLocationModel()
        self.metadata = AMBMetadata()
        self.content = AMBEventContent()
        super.init()
    }

    public init?(json: [String: Any]) {
        guard let id = json[AMBConstants.eventIdKey] as? String,
            let contentDict = json[AMBConstants.contentKey] as? [String: Any],
            let content = AMBEventContent(json: contentDict) else {
                return nil
        }
        self.id = id
        self.content = content
        self.signature = self.content.signature
        self.creator = self.content.idData.createdBy
        self.assetId = self.content.idData.assetId
        self.accessLevel = self.content.idData.accessLevel
        self.timestamp = self.content.idData.timestamp
        self.formattedSections = AMBSectionFormatter.getFormattedSections(fromData: json)
        self.date = AMBDateFetcher.getDate(fromTimestamp: self.timestamp)
        self.type = AMBDataParserHelper.getTypeFromDataDicitionaries(dataDict: self.content.data)
        self.name = AMBDataParserHelper.getNameFromDataDicitionaries(dataDict: self.content.data)
        self.assetInfo = AMBDataParserHelper.getAssetInfoFromDataDicitionaries(dataDict: self.content.data)
        self.location = AMBDataParserHelper.getLocationFromDataDicitionaries(dataDict: self.content.data)
        let metadataDict = json[AMBConstants.metadataKey] as? [String: Any]
        self.metadata = AMBMetadata(json: metadataDict)
        super.init()
    }
}
