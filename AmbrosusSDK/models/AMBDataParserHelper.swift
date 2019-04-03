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

class AMBDataParserHelper: NSObject {

    /// Used for get type string from data dictionary(json)
    ///
    /// - Parameter data: The json data
    /// - Returns: type: String where stored type of event
    static func getTypeFromDataDicitionaries(dataDict: [[String: Any]]) -> String? {
        return dataDict.first?[AMBConstants.typeKey] as? String
    }

    /// Used for get name string from data dictionary(json)
    ///
    /// - Parameter: data: The json data
    /// - Returns: name: String where stored name of event
    static func getNameFromDataDicitionaries(dataDict: [[String: Any]]) -> String? {
        let nameDictionary = dataDict.first { $0[AMBConstants.nameKey] != nil }
        return nameDictionary?[AMBConstants.nameKey] as? String
    }

    /// Used for get asset info model from data dictionary(json)
    ///
    /// - Parameter data: The json data
    /// - Returns: assetInfo: model where stored Asset information(name,image and etc)
    static func getAssetInfoFromDataDicitionaries(dataDict: [[String: Any]]) -> AMBAssetInfo? {
        let assetInfoDictionary = dataDict.first { ($0[AMBConstants.typeKey] as? String) == AMBConstants.assetInfoType }
        return AMBAssetInfo(json: assetInfoDictionary)
    }

    /// Used for get location model from data dictionary(json)
    ///
    /// - Parameter data: The json data
    /// - Returns: location: location model of this event
    static func getLocationFromDataDicitionaries(dataDict: [[String: Any]]) -> AMBLocationModel? {
        let locationContainerDictionary = dataDict.first { ($0[AMBConstants.typeKey] as? String) == AMBConstants.locationType }
        let locationDictionary = locationContainerDictionary?[AMBConstants.locationKey] as? [String: Any]
        let geoJsonDictionary = dataDict.compactMap { $0[AMBConstants.geoJsonKey] as? [String: Any] }.first
        let geometryDictionary = locationDictionary?[AMBConstants.geometryKey] as? [String: Any]
        let geoDictionary = geometryDictionary ?? geoJsonDictionary
        let coordinates = geoDictionary?[AMBConstants.coordinatesKey] as? [NSNumber] ?? []
        let hasCoordinates = coordinates.count > 1
        // Make sure lattitude longitude are available and have more than one value
        let lattitude = hasCoordinates ? coordinates[0] : nil
        let longitude = hasCoordinates ? coordinates[1] : nil
        let locationName = locationContainerDictionary?[AMBConstants.nameKey] as? String
        return AMBLocationModel(lattitude: lattitude, longitude: longitude, locationName: locationName)
    }

}
