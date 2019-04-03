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

internal let ambLog = OSLog(subsystem: "com.ambrosus.sdk", category: "ambrosus_sdk")

/// A Network Layer for interfacing with the Ambrosus API
@objcMembers public final class AMBNetwork: NSObject {

    enum ResponseType {
        case json,
        data
    }

    /// The base path for the Ambrosus API, modify this to change the endpoint if needed
    fileprivate static var endpointBasePath: String = "https://gateway-test.ambrosus.com/"

    public static func setBaseUrlPath(with path: String) {
        endpointBasePath = path
    }

    public static func getBaseUrlPath() -> String {
        return endpointBasePath
    }

    static var authorizationToken: String?

    public static func createToken(createdBy: String, timestamp: Int = Int(Date().timeIntervalSince1970), completion: @escaping (_ token: String?, _ error: String?) -> Void) {
        let idData: [String: Any] = [
           AMBConstants.createdByKey: createdBy,
           AMBConstants.validUntilKey: timestamp
        ]
        guard let signature = AMBWeb3Manager.sharedInstance.generateSignature(for: idData) else {
            completion(nil, AMBErrorsHandler.signatureErrorString)
            return
        }
        let tokenPayload: [String: Any] = [AMBConstants.signatureKey: signature, AMBConstants.idDataKey: idData]
        guard let serializedTokenPayload = AMBWeb3Manager.sharedInstance.serialize(value: tokenPayload) else {
            completion(nil, AMBErrorsHandler.validationTokenCreationErrorString)
            return
        }
        let utf8TokenValue = serializedTokenPayload.data(using: .utf8)
        guard let token = utf8TokenValue?.base64EncodedString() else {
            completion(nil, AMBErrorsHandler.base64ErrorString)
            return
        }
        setAuthorizationToken(with: token)
        completion(token, nil)
    }

    public static func setAuthorizationToken(with token: String) {
        authorizationToken = token
    }

    /// Request JSON data back from the API
    ///
    /// - Parameters:
    ///   - path: The path to the required endpoint, not including the basePath of "https://network.ambrosus.com/"
    ///   - completion: The data returned (optional, nil if request fails)
    private static func request(path: String,
                                responseType: ResponseType = .json,
                                authorizationType: AuthorizationType,
                                completion: @escaping (_ data: Any?, _ error: String?) -> Void) {
        guard let url = URL(string: path) else {
            completion(nil, nil)
            os_log("%@", log: ambLog, type: .debug, AMBErrorsHandler.urlInvalidErrorString)
            return
        }
        let request = authorizationType.getURLRequest(url: url, responseType: responseType)
        completeRequest(with: request, responseType: responseType) { data, error in
            completion(data, error)
        }
    }

    private static func completeRequest(with request: URLRequest,
                                        responseType: ResponseType,
                                        completion: @escaping (_ data: Any?, _ error: String?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, error in

            guard let data = data else {
                completion(nil, error?.localizedDescription)
                os_log("%@", log: ambLog, type: .debug, error?.localizedDescription ?? "")
                return
            }
            if responseType == .data {
                completion(data, nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completion(json, nil)
            } catch {
                completion(nil, error.localizedDescription)
                os_log("%@", log: ambLog, type: .debug, error.localizedDescription)
            }
        }

         dataTask.resume()
    }

    internal static func postRequest(path: String,
                                     attributes: [String: Any],
                                     responseType: ResponseType = .json,
                                     authorizationType: AuthorizationType = .none,
                                     completion: @escaping (_ data: Any?, _ error: String?) -> Void) {
        guard let url = URL(string: path) else {
            completion(nil, AMBErrorsHandler.urlInvalidErrorString)
            os_log("%@", log: ambLog, type: .debug, AMBErrorsHandler.urlInvalidErrorString)
            return
        }
        var request = authorizationType.getURLRequest(url: url, responseType: responseType)
        do {
            let data = try JSONSerialization.data(withJSONObject: attributes, options: [])
            request.httpMethod = "POST"
            request.httpBody = data

            completeRequest(with: request, responseType: responseType) { data, _ in
                completion(data, nil)
            }
        } catch {
            completion(nil, error.localizedDescription)
            os_log("%@", log: ambLog, type: .debug, error.localizedDescription)
        }
    }

    /// Gets events back based on a scanner identifier
    ///
    /// - Parameters:
    ///   - query: The identifier including type of scanner e.g. [gtin]=0043345534
    ///   - completion: The events if available, nil if none returned
    public static func requestEvents(fromQuery query: String, completion: @escaping (_ data: [AMBEvent]?, _ error: String?) -> Void) {
        let path = endpointBasePath + "events?data" + query
        request(path: path, authorizationType: .none) { data, _ in
            fetchEvents(from: data, completion: { events in
                guard let events = events else {
                    let errorMsg = AMBErrorsHandler.noEventsForQueryErrorString + query
                    os_log("%@", log: ambLog, type: .debug, errorMsg)
                    completion(nil, errorMsg)
                    return
                }
                completion(events, nil)
            })
        }
    }

    /// Creates an Asset on AMB-NET and returns a local instance
    ///
    /// - Parameters:
    ///   - timestamp: The unix timestamp at which point the Asset was created
    ///   - createdBy: The public key of the user who created the Asset
    ///   - privateKey: The private key of the user who created the Asset
    ///   - sequenceNumber: Used to assure all Assets are unique
    ///   - completion: The Asset if created successfully, otherwise an error
    public static func createAsset(timestamp: Int = Int(Date().timeIntervalSince1970),
                                   createdBy: String,
                                   sequenceNumber: Int = 3,
                                   completion: @escaping (_ asset: AMBAsset?, _ error: String?) -> Void) {
        guard !createdBy.isEmpty else {
            completion(nil, AMBErrorsHandler.creaatedByEmptyErrorString)
            return
        }
        let url = endpointBasePath + "assets"

        let idData: [String: Any] = [AMBConstants.timestampKey: timestamp,
                                     AMBConstants.createdByKey: createdBy,
                                     AMBConstants.sequenceNumberKey: sequenceNumber]
        guard let signature = AMBWeb3Manager.sharedInstance.generateSignature(for: idData) else {
            completion(nil, AMBErrorsHandler.signatureErrorString)
            return
        }
        let createAssetData: [String: Any] = [AMBConstants.contentKey: [AMBConstants.signatureKey: signature, AMBConstants.idDataKey: idData]]

        AMBNetwork.postRequest(path: url, attributes: createAssetData) { response, error in
            guard let responseData = response as? [String: Any],
                let asset = AMBAsset(json: responseData) else {
                    completion(nil, error)
                    return
            }

            completion(asset, error)
        }
    }

    /// Creates an Event for a specified Asset and returns a local instance of the Event
    ///
    /// - Parameters:
    ///   - assetId: The asset id for which this Event is associated
    ///   - createdBy: The public key of the user who created the Event
    ///   - privateKey: The private key of the user who created the Event
    ///   - timestamp: The unix timestamp at which point the Event was created
    ///   - accessLevel: What level of access a user must have to view the event - default: 0
    ///   - data: An array of key-value pairs of information to describe the Event,
    ///     required to have at least one entry
    public static func createEvent(assetId: String,
                                   createdBy: String,
                                   timestamp: Int = Int(Date().timeIntervalSince1970),
                                   accessLevel: Int = 0,
                                   data: [[String: Any]],
                                   completion: @escaping (_ event: AMBEvent?, _ error: String?) -> Void) {
        guard !createdBy.isEmpty else {
            completion(nil, AMBErrorsHandler.creaatedByEmptyErrorString)
            return
        }

        guard !data.isEmpty else {
            completion(nil, AMBErrorsHandler.dataEmptyErrorString)
            return
        }
        let url = endpointBasePath + "assets/" + assetId + "/events"

        guard let dataHash = AMBWeb3Manager.sharedInstance.getHash(for: data) else {
            completion(nil, AMBErrorsHandler.getHashErrorString)
            return
        }
        let idData: [String: Any] = [
            AMBConstants.assetIdKey: assetId,
            AMBConstants.createdByKey: createdBy,
            AMBConstants.accessLevelKey: accessLevel,
            AMBConstants.timestampKey: timestamp,
            AMBConstants.dataHashKey: dataHash
        ]
        guard let signature = AMBWeb3Manager.sharedInstance.generateSignature(for: idData) else {
            completion(nil, AMBErrorsHandler.signatureErrorString)
            return
        }
        let createEventData: [String: Any] = [AMBConstants.contentKey: [AMBConstants.signatureKey: signature, AMBConstants.idDataKey: idData, AMBConstants.dataKey: data]]
        AMBNetwork.postRequest(path: url, attributes: createEventData) { response, error in
            guard let responseData = response as? [String: Any],
                let event = AMBEvent(json: responseData) else {
                    completion(nil, error)
                    return
            }

            completion(event, error)
        }
    }

    /// Gets a single asset back directly from an ID
    ///
    /// - Parameters:
    ///   - id: The identifier associated with the desired asset
    ///   - completion: The asset if available, nil if unavailable
    public static func requestAsset(fromId id: String, completion: @escaping (_ data: AMBAsset?, _ error: String?) -> Void) {
        if let asset = AMBDataStore.sharedInstance.assetStore.fetch(withAssetId: id) {
            os_log("%@", log: ambLog, type: .debug, "Asset already downloaded, fetching from data store")
            completion(asset, nil)
            return
        }
        let path = endpointBasePath + "assets/" + id
        request(path: path, authorizationType: .none) { data, error in
            guard let data = data as? [String: Any] else {
                let errorMsg = "\(AMBErrorsHandler.noAssetsForIdErrorString)\(id)"
                os_log("%@", log: ambLog, type: .debug, errorMsg)
                completion(nil, errorMsg)
                return
            }
            let asset = AMBAsset(json: data)
            completion(asset, error)
        }
    }

    /// Fetches the events associated with an asset ID
    ///
    /// - Parameters:
    ///   - id: The identifier associated with the asset with desired events
    ///   - completion: The array of ev.noneents if available, nil if unavailable
    private static func fetchEvents(from data: Any?, completion: @escaping (_ data: [AMBEvent]?) -> Void) {
        guard let data = data as? [String: Any],
            let results = data["results"] as? [[String: Any]] else {
                os_log("%@", log: ambLog, type: .debug, AMBErrorsHandler.noEventsForDataErrorString)
                completion(nil)
                return
        }
        let events = results.compactMap { AMBEvent(json: $0) }
        completion(events)
    }

    /// Gets an array of evnts back directly from an assetID
    ///
    /// - Parameters:
    ///   - id: The identifier associated with the desired asset
    ///   - completion: The events if available, nil if unavailable
    public static func requestEvents(fromAssetId id: String, completion: @escaping (_ data: [AMBEvent]?, _ error: String?) -> Void) {
        let path = endpointBasePath + "events?assetId=" + id
        request(path: path, authorizationType: .none) { data, _ in
            fetchEvents(from: data, completion: { events in
                guard let events = events else {
                    let errorMsg = "\(AMBErrorsHandler.noAssetsForIdErrorString)\(id)"
                    os_log("%@", log: ambLog, type: .debug, errorMsg)
                    completion(nil, errorMsg)
                    return
                }
                completion(events, nil)
            })
        }
    }

    /// Downloads an image from a URL, if the image is already stored in the cache it will fetch it directly
    ///
    /// - Parameters:
    ///   - url: The URL of the image to download
    ///   - completion: The image if available, and optional error
    public static func requestImage(from url: URL, completion: @escaping (_ image: UIImage?, _ error: String? ) -> Void) {
        let urlString =  url.absoluteString
        let urlNSString = urlString  as NSString
        if let cachedImage = AMBDataStore.sharedInstance.imageCache.object(forKey: urlNSString) {
            completion(cachedImage, nil)
        } else {
            request(path: urlString, responseType: .data, authorizationType: .none, completion: { data, error in
                if let data = data as? Data, let image = UIImage(data: data) {
                    AMBDataStore.sharedInstance.imageCache.setObject(image, forKey: urlNSString)
                    completion(image, nil)
                } else {
                    os_log("%@", log: ambLog, type: .debug, AMBErrorsHandler.imageMissingErrorString + urlString)
                    completion(nil, error)
                }
            })
        }
    }
}

internal enum AuthorizationType {
    case token(String), privateKey(String), none

    func getURLRequest(url: URL, responseType: AMBNetwork.ResponseType) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        if responseType == .json {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let authorizationValue: String? = {
            switch self {
            case .token(let token):
                return "AMB_TOKEN \(token)"
            case .privateKey(let userSecret):
                return "AMB \(userSecret)"
            default:
                return nil
            }
        }()

        guard let value = authorizationValue else {
            return urlRequest
        }

        urlRequest.addValue(value, forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
