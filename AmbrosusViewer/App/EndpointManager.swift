//
//  EndpointManager.swift
//  AmbrosusViewer
//
//  Created by Stein, Maxwell on 8/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import AmbrosusSDK

final class EndpointManager {

    let endpoints = ["https://gateway-test.ambrosus.com/", "https://gateway-dev.ambrosus.com/"]
    static let selectedEndpointUserDefaultsKey = "selectedEndpointKey"

    static let shared = EndpointManager()

    func set(with index: Int) {
        AMBNetwork.setBaseUrlPath(with: endpoints[index])
    }
}
