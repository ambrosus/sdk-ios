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
import AmbrosusSDK

final class SampleFetcher {

    func fetch() {
        requestSampleJSON()
    }
    
    private func requestSampleJSON() {
        requestSamples(assetPath: "CowAsset", eventsPath: "CowEvents")
        requestSamples(assetPath: "PharmacyAsset", eventsPath: "PharmacyEvents")
        requestSamples(assetPath: "PharmacyAsset2", eventsPath: "PharmacyEvents2")
    }
    
    private func requestSamples(assetPath: String, eventsPath: String) {
        if let assetDictionary = requestJSON(path: assetPath) as? [String: Any],
            let asset = AMBAsset(json: assetDictionary) {
                AMBDataStore.sharedInstance.assetStore.insert(asset)
        }

        guard let eventDictionaries = requestJSON(path: eventsPath) as? [String: Any],
            let eventPairs = eventDictionaries["results"] as? [[String: Any]] else {
                return
        }
        let events = eventPairs.compactMap { AMBEvent(json: $0) }
        AMBDataStore.sharedInstance.eventStore.insert(events)
    }
    
    private func requestJSON(path: String) -> Any? {
        if let path = Bundle.main.path(forResource: path, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                return jsonResult
            } catch {
                return nil
            }
        }
        return nil
    }
    
}
