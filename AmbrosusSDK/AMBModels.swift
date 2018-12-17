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
import os.log

// MARK: - Key Name Constants

fileprivate let contentKey = "content"
fileprivate let metadataKey = "metadata"
fileprivate let signatureKey = "signature"
fileprivate let idDataKey = "idData"
fileprivate let createdByKey = "createdBy"
fileprivate let timestampKey = "timestamp"
fileprivate let assetIdKey = "assetId"
fileprivate let productImageKey = "productImage"
fileprivate let nameKey = "name"
fileprivate let typeKey = "type"
fileprivate let accessLevelKey = "accessLevel"
fileprivate let imagesKey = "images"
fileprivate let defaultKey = "default"
fileprivate let urlKey = "url"
fileprivate let eventIdKey = "eventId"
fileprivate let dataKey = "data"

/// Location Keys
fileprivate let locationKey = "location"
fileprivate let geometryKey = "geometry"
fileprivate let geoJsonKey = "geoJson"
fileprivate let propertiesKey = "properties"
fileprivate let coordinatesKey = "coordinates"


/// Event Types
fileprivate let eventTypePrefix = "ambrosus."
fileprivate let assetInfoType = eventTypePrefix + "asset.info"
fileprivate let locationType = eventTypePrefix + "event.location"

/// An array of type [String: [String: Any]] useful for formatting complex AMB-Net Data
/// to an easy to use Data Source for display, formattedSections are accessible from both assets and events
public typealias AMBFormattedSections = [[String: [String: Any]]]

private struct SectionFormatter {

    static func getDescriptiveName(from dictionary: [String: Any]) -> String? {
        guard let type = dictionary[typeKey] as? String,
            type.contains(eventTypePrefix) else {
                return nil
        }

        return type
    }

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
            for additionalSection in additionalSections {
                for key in additionalSection.keys {
                    dictionary.removeValue(forKey: key)
                }
            }
            return additionalSections
        }

        for key in formattedData.keys {
            if var dictionary = formattedData[key] as? [String: Any] {
                formattedData.removeValue(forKey: key)
                sections.append(contentsOf: fetchAdditionalSections(dictionary: &dictionary))
                let name = getDescriptiveName(from: dictionary) ?? key
                let dataSection = [name: dictionary]
                sections.append(dataSection)

                // If this key contains an array of dictionaries, extract all dictionaries from the array
            } else if let dictionaries = formattedData[key] as? [[String: Any]] {
                for (i, var dictionary) in dictionaries.enumerated() {
                    // index the dictionaries that belong to the same parent
                    sections.append(contentsOf: fetchAdditionalSections(dictionary: &dictionary))
                    let keyIndexed = i > 0 ? key + " \(i+1)" : key
                    let name = getDescriptiveName(from: dictionary) ?? keyIndexed
                    let dataSection = [name: dictionary]
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

fileprivate class DateFetcher {

    static func getDate(fromTimestamp timestamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        // If the date timestamp is over 1 trillion it is in milliseconds and needs to be converted to seconds first to correctly fetch the date
        let timeInterval: TimeInterval = timestamp > 1000000000000 ? timestamp / 1000 : timestamp
        let date: Date = Date(timeIntervalSince1970: timeInterval)
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

}

fileprivate protocol AMBSharedFields: AnyObject {
    /// A signature unique to this instance, used to verify authenticity
    var signature: String { get }

    /// A formatted date converted from the creation timestamp (e.g. Sep 17, 2017)
    var date: String { get }

    /// The address of the creator of this instance
    var creator: String { get }

    /// A timestamp in seconds of when this instance was created
    var timestamp: Double { get }

    /// Formatted data sections, useful for displaying details about this instance in a table or collection view
    var formattedSections: AMBFormattedSections { get }
}

/// Assets are any item that can flow through a supply chain
@objcMembers public class AMBAsset: NSObject, AMBSharedFields {

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

    public override init() {
        self.signature = ""
        self.date = ""
        self.creator = ""
        self.id = ""
        self.timestamp = 0
        self.formattedSections = []
        super.init()
    }

    public init?(json: [String: Any]) {
        guard let content = json[contentKey] as? [String: Any],
            let signature = content[signatureKey] as? String,
            let idData = content[idDataKey] as? [String: Any],
            let creator = idData[createdByKey] as? String,
            let id = json[assetIdKey] as? String,
            let timestamp = idData[timestampKey] as? Double else {
                return nil
        }

        self.signature = signature
        self.creator = creator
        self.id = id
        self.timestamp = timestamp
        self.date = DateFetcher.getDate(fromTimestamp: timestamp)
        self.formattedSections = SectionFormatter.getFormattedSections(fromData: json)
        super.init()
    }
     
    /// An array of events associated with this asset saved inside the AMBDataStore Event Store, if any
    public var events: [AMBEvent]? {
        return AMBDataStore.sharedInstance.eventStore.fetchEvents(forAssetId: id)
    }
    
    fileprivate var assetInfo: AMBEvent.AssetInfo? {
        return events?.filter { $0.assetInfo != nil }.first?.assetInfo
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

/// Events are anything that occured to an asset in the process of moving through the supply chain
@objcMembers public class AMBEvent: NSObject, AMBSharedFields {
    
    fileprivate struct AssetInfo {
        public let name: String
        public let imageDictionary: [String: Any]
        public let imagePath: String
        
        init?(json: [String: Any]?) {
            guard let json = json,
                let name = json[nameKey] as? String,
                let imageDictionary = json[imagesKey] as? [String: Any],
                let imagesDefaultDictionary = imageDictionary[defaultKey] as? [String: Any],
                let imagePath = imagesDefaultDictionary[urlKey] as? String else {
                    return nil
            }
            self.name = name
            self.imageDictionary = imageDictionary
            self.imagePath = imagePath
        }
    }

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
    public let type: String

    /// A timestamp in seconds of when this event was created
    public let timestamp: Double

    /// Determines who has access to view this event, 0 = public. The higher the level the more restricted the event is
    public let accessLevel: Int

    /// Formatted data sections, useful for displaying details about this instance in a table or collection view
    public let formattedSections: AMBFormattedSections
    
    /// Contains asset info such as name and image
    fileprivate let assetInfo: AssetInfo?

    /// The lattitude coordinates for this events location
    public let lattitude: NSNumber?

    /// The longitude coordinates for this events location
    public let longitude: NSNumber?

    /// A name describing where this event occured
    public let locationName: String?

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
        self.lattitude = nil
        self.longitude = nil
        self.locationName = nil
        super.init()
    }

    public init?(json: [String: Any]) {
        guard let id = json[eventIdKey] as? String,
            let content = json[contentKey] as? [String: Any],
            let idData = content[idDataKey] as? [String: Any],
            let dataDictionaries = (content[dataKey] as? [[String: Any]]),
            let signature = content[signatureKey] as? String,
            let creator = idData[createdByKey] as? String,
            let type = dataDictionaries.first?[typeKey] as? String,
            let assetId = idData[assetIdKey] as? String,
            let timestamp = idData[timestampKey] as? Double,
            let accessLevel = idData[accessLevelKey] as? Int else {
                return nil
        }

        self.formattedSections = SectionFormatter.getFormattedSections(fromData: json)
        self.signature = signature
        self.creator = creator
        self.id = id
        self.assetId = assetId
        self.type = type
        self.accessLevel = accessLevel
        self.timestamp = timestamp
        self.date = DateFetcher.getDate(fromTimestamp: timestamp)

        let nameDictionary = dataDictionaries.filter { $0[nameKey] != nil }.first
        self.name = nameDictionary?[nameKey] as? String

        let assetInfoDictionary = dataDictionaries.filter { ($0[typeKey] as? String) == assetInfoType }.first
        self.assetInfo = AssetInfo(json: assetInfoDictionary)

        let locationContainerDictionary = dataDictionaries.filter { ($0[typeKey] as? String) == locationType }.first
        let locationDictionary = locationContainerDictionary?[locationKey] as? [String: Any]
        let geoJsonDictionary = dataDictionaries.compactMap { $0[geoJsonKey] as? [String: Any] }.first
        let geometryDictionary = locationDictionary?[geometryKey] as? [String: Any]
        let geoDictionary = geometryDictionary ?? geoJsonDictionary
        let coordinates = geoDictionary?[coordinatesKey] as? [NSNumber] ?? []
        let hasCoordinates = coordinates.count > 1
        // Make sure lattitude longitude are available and have more than one value
        lattitude = hasCoordinates ? coordinates[0] : nil
        longitude = hasCoordinates ? coordinates[1] : nil

        locationName = locationContainerDictionary?[nameKey] as? String

        super.init()
    }
}
