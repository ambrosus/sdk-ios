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

import Foundation
import os.log

@objcMembers public final class AMBAccount: NSObject {

    public let publicKey: String
    public let privateKey: String?
    public let registeredBy: String

    public let name: String
    public let image: UIImage
    public let accessLevel: Int
    public let registeredOn: Int
    public let permissions: [String]

    private let randomName: String = {
        let randomNumber = Int(arc4random_uniform(5))
        let names = ["Joe the Warrior", "RebeccaLarper88", "PiersonDogLover42", "Fred Harrison", "Douglas Farrenheim"]
        return names[randomNumber]
    }()

    private let randomImage: UIImage = {
        let randomNumber = Int(arc4random_uniform(5))
        let images = [#imageLiteral(resourceName: "AccountsSample1"), #imageLiteral(resourceName: "AccountsSample2"), #imageLiteral(resourceName: "AccountsSample3"), #imageLiteral(resourceName: "AccountsSample4"), #imageLiteral(resourceName: "AccountsSample5")]
        return images[randomNumber]
    }()

    init?(json: [String: Any]) {
        guard let publicKey = json["address"] as? String,
            let registeredBy = json["registeredBy"] as? String,
            let accessLevel = json["accessLevel"] as? Int,
            let registeredOn = json["registeredOn"] as? Int else {
                return nil
        }
        self.publicKey = publicKey
        self.privateKey = nil
        self.registeredBy = registeredBy
        self.name = randomName
        self.image = randomImage
        self.permissions = json["permissions"] as? [String] ?? []
        self.accessLevel = accessLevel
        self.registeredOn = registeredOn
    }

    public init(publicKey: String, privateKey: String, name: String, image: UIImage, accessLevel: Int = 0) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.registeredBy = ""
        self.name = name
        self.image = image
        self.accessLevel = accessLevel
        self.permissions = []
        self.registeredOn = 0
    }
}
