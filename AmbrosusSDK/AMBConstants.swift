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

struct AMBConstants {
    static let contentKey = "content"
    static let metadataKey = "metadata"
    static let signatureKey = "signature"
    static let idDataKey = "idData"
    static let createdByKey = "createdBy"
    static let timestampKey = "timestamp"
    static let assetIdKey = "assetId"
    static let productImageKey = "productImage"
    static let nameKey = "name"
    static let typeKey = "type"
    static let accessLevelKey = "accessLevel"
    static let imagesKey = "images"
    static let defaultKey = "default"
    static let urlKey = "url"
    static let eventIdKey = "eventId"
    static let dataKey = "data"
    static let validUntilKey = "validUntil"
    static let sequenceNumberKey = "sequenceNumber"
    static let dataHashKey = "dataHash"

    /// Location Keys
    static let locationKey = "location"
    static let geometryKey = "geoJson"
    static let geoJsonKey = "geoJson"
    static let propertiesKey = "properties"
    static let coordinatesKey = "coordinates"

    /// Event Types
    static let eventTypePrefix = "ambrosus."
    static let assetInfoType = eventTypePrefix + "asset.info"
    static let locationType = eventTypePrefix + "event.location"

    //Accounts

    static let registerAccountKey = "register_account"
    static let createEntityKey = "create_entity"
    static let addressKey = "address"
    static let permissionsKey = "permissions"
}
