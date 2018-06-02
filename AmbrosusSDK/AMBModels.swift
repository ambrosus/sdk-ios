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

// MARK: - Key Name Constants

fileprivate let contentKey = "content"
fileprivate let metadataKey = "metadata"
fileprivate let signatureKey = "signature"
fileprivate let idDataKey = "idData"
fileprivate let createdByKey = "createdBy"
fileprivate let timestampKey = "timestamp"
fileprivate let assetIdKey = "assetId"
fileprivate let entriesKey = "entries"
fileprivate let productImageKey = "productImage"
fileprivate let nameKey = "name"
fileprivate let typeKey = "type"
fileprivate let accessLevelKey = "accessLevel"
fileprivate let imagesKey = "images"
fileprivate let eventIdKey = "eventId"
fileprivate let dataKey = "data"

/// Location Keys
fileprivate let locationKey = "location"
fileprivate let geometryKey = "geometry"
fileprivate let propertiesKey = "properties"
fileprivate let coordinatesKey = "coordinates"

/// An array of type [String: [String: Any]] useful for formatting complex AMB-Net Data
/// to an easy to use Data Source for display, formattedSections are accessible from both assets and events
public typealias AMBFormattedSections = [[String: [String: Any]]]

private struct SectionFormatter {

    /// Recursively traverses the data for an AMBModel and extracts an array that can be used
    /// as a data source for display
    ///
    /// - Parameter data: The dictionary to extract sub dictionaries from
    /// - Returns: The formatted data source
    private static func getDictionaries(_ data: [String: Any]) -> AMBFormattedSections {
        var formattedData = data
        var sections: AMBFormattedSections = []

        /// Finds all additional subdictionarys and removes those values from the main dictionary
        ///
        /// - Parameter dictionary: The dictionary with subdictionaries available, removes those values
        /// - Returns: The additional subdictionaries as formatted sections
        func fetchAdditionalSections(dictionary: inout [String: Any]) -> AMBFormattedSections {
            let additionalSections = getDictionaries(dictionary)
            additionalSections.forEach {
                $0.keys.forEach { dictionary.removeValue(forKey: $0)}
            }
            return additionalSections
        }

        for key in formattedData.keys {
            if var dictionary = formattedData[key] as? [String: Any] {
                formattedData.removeValue(forKey: key)
                sections.append(contentsOf: fetchAdditionalSections(dictionary: &dictionary))
                let dataSection = [key: dictionary]
                sections.append(dataSection)

                // If this key contains an array of dictionaries, extract all dictionaries from the array
            } else if let dictionaries = formattedData[key] as? [[String: Any]] {
                for (i, var dictionary) in dictionaries.enumerated() {
                    // index the dictionaries that belong to the same parent
                    sections.append(contentsOf: fetchAdditionalSections(dictionary: &dictionary))
                    let keyIndexed = i > 0 ? key + " \(i+1)" : key
                    let dataSection = [keyIndexed: dictionary]
                    sections.append(dataSection)
                }
            }
        }
        return sections
    }

    static func getFormattedSections(fromData data: [String: Any]) -> AMBFormattedSections {
        var formattedData = data

        data.forEach {
            if $0.value is [String: Any] || $0.value is [[String: Any]] {
                formattedData.removeValue(forKey: $0.key)
            }
        }
        var sections = getDictionaries(data)
        for (i, section) in sections.enumerated() {
            if var dictionary = section[contentKey] {
                for key in formattedData.keys {
                    dictionary[key] = formattedData[key]
                }
                sections.remove(at: i)
                sections.append([contentKey: dictionary])
            }
        }
        for (i, section) in sections.enumerated() {
            for value in section.values {
                if value.values.isEmpty {
                    sections.remove(at: i)
                }
            }
        }
        return sections
    }

}

/// The base model that both Assets and Events inherit from
@objcMembers public class AMBModel: NSObject {

    /// A signature unique to this Asset, used to verify authenticity
    public let signature: String

    /// A formatted date converted from the creation timestamp (e.g. Sep 17, 2017)
    public private(set) var date: String

    /// The address of the creator of this Object
    public let creator: String

    /// A timestamp in seconds of when this Object was created
    public let timestamp: Double

    /// Formatted data sections, useful for displaying details about this Asset in a table or collection view
    public let formattedSections: AMBFormattedSections

    override internal init() {
        self.signature = ""
        self.date = ""
        self.creator = ""
        self.timestamp = 0
        self.formattedSections = []
    }

    internal init?(json: [String: Any]) {
        guard let content = json[contentKey] as? [String: Any],
            let signature = content[signatureKey] as? String,
            let idData = content[idDataKey] as? [String: Any],
            let creator = idData[createdByKey] as? String,
            let timestamp = idData[timestampKey] as? Double else {
                return nil
        }

        self.signature = signature
        self.creator = creator
        self.timestamp = timestamp
        self.formattedSections = SectionFormatter.getFormattedSections(fromData: json)

        let date: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            // If the date timestamp is over 1 trillion it is in milliseconds and needs to be converted to seconds first to correctly fetch the date
            let timeInterval: TimeInterval = timestamp > 1000000000000 ? timestamp / 1000 : timestamp
            let date: Date = Date(timeIntervalSince1970: timeInterval)
            let dateString = dateFormatter.string(from: date)
            return dateString
        }()
        self.date = date
    }
}

/// Assets are any item that can flow through a supply chain
@objcMembers public class AMBAsset: AMBModel {

    /// The unique identifier associated with only this Asset, used to map an asset to its associated Events
    public let id: String

    public override init() {
        self.id = ""
        super.init()
    }

    public override init?(json: [String: Any]) {
        guard let id = json[assetIdKey] as? String else {
            return nil
        }

        self.id = id
        super.init(json: json)
    }
     
    /// An array of events associated with this Asset saved inside the AMBDataStore Event Store, if any
    public var events: [AMBEvent]? {
        return AMBDataStore.sharedInstance.eventStore.fetchEvents(forAssetId: id)
    }
    
    fileprivate var assetInfo: AMBEvent.AssetInfo? {
        return events?.filter { $0.assetInfo != nil }.first?.assetInfo
    }
     
    /// A descriptive name of the asset, optional
    public var name: String? {
        return assetInfo?.name
    }
    
    /// Finds an image if one is available for the asset
    public var imageURLString: String? {
        return assetInfo?.images.values.first
    }

}

/// Assets are any item that can flow through a supply chain
@objcMembers public class AMBEvent: AMBModel {
    
    fileprivate struct AssetInfo {
        public let name: String
        public let images: [String: String]
        
        init?(json: [String: Any]) {
            guard let name = json[nameKey] as? String,
                let images = json[imagesKey] as? [String: String] else {
                    return nil
            }
            self.name = name
            self.images = images
        }
    }

    /// The unique identifier associated with only this Asset, used to map an asset to its associated Events
    public let id: String

    /// The unique identifier for the asset this event happened to
    public let assetId: String

    /// The type describes the category of event that occurs, can be used as a name for the event as well
    public let type: String

    /// Determines who has access to view this event, 0 = public. The higher the level the more restricted the event is
    public let accessLevel: Int
    
    /// If this event contains asset info such as name and image it is stored in this struct
    fileprivate let assetInfo: AssetInfo?

    /// Finds an image if one is available for the event
    public private(set) var imageURLString: String? = nil
    
    /// Finds an image if one is available for the event
    public private(set) var assetName: String? = nil

    /// The lattitude coordinates for this events location
    public private(set) var lattitude: NSNumber? = nil

    /// The longitude coordinates for this events location
    public private(set) var longitude: NSNumber? = nil

    /// A name describing where this event occured
    public private(set) var locationName: String? = nil

    public override init() {
        self.id = ""
        self.assetId = ""
        self.type = ""
        self.accessLevel = 0
        self.assetInfo = nil
        super.init()
    }

    public override init?(json: [String: Any]) {
        guard let id = json[eventIdKey] as? String,
            let content = json[contentKey] as? [String: Any],
            let idData = content[idDataKey] as? [String: Any],
            let data = (content[dataKey] as? [[String: Any]])?.first,
            let type = data[typeKey] as? String,
            let assetId = idData[assetIdKey] as? String,
            let accessLevel = idData[accessLevelKey] as? Int else {
                return nil
        }

        self.id = id
        self.assetId = assetId
        self.type = type
        self.accessLevel = accessLevel
        self.assetInfo = type.contains("asset_info") ? AssetInfo(json: data) : nil
        super.init(json: json)

        let geometryDictionary = formattedSections.flatMap { $0[geometryKey] }.first
        let propertiesDictionary = formattedSections.flatMap { $0[propertiesKey] }.first

        // Make sure lattitude longitude is available and has more than 1 value
        if let lattitudeLongitude = geometryDictionary?[coordinatesKey] as? [NSNumber], lattitudeLongitude.count > 1 {
            lattitude = lattitudeLongitude[0]
            longitude = lattitudeLongitude[1]
        }
        locationName = propertiesDictionary?[nameKey] as? String
    }
}
