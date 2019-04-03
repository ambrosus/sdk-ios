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

import XCTest
import BigInt
import web3swift
@testable import AmbrosusBlockchainSDK

private let key1 = "0x8105455eab3616fed1e3fe1c2d006efa52e98c3a"
private let key2 = "0x81342a9d1cc5282f88ee7ecbd6379b134ef8012c"

class AmbrosusBlockchainServiceTests: XCTestCase {

    /// A mapping of debug accounts addresses to the 12 word mnemonics used to generate them
    let testAccounts: [String: String] = [
        key1: "limit rain hamster fire draft diet wage vapor hood belt suit again",
        key2: "matrix tattoo example file raccoon thrive safe envelope razor reward aunt hello"
    ]

    let service = AmbrosusBlockchainService()
    let queue = AmbrosusBlockchainService.queue

    override func setUp() {
        queue.sync {
            service.start()
            service.setKeystore(from: testAccounts[key1]!)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetAddress() {
        queue.sync {
            let address = service.address!.address.lowercased()
            XCTAssertEqual(address, key1, "Address should match the valid address for the keystore")
        }
    }

    func testFetchAmberBalance() {
        var balance: BigUInt?
        var error: BlockchainAPIError?
        let expectation = self.expectation(description: "FetchAmber")
        self.service.fetchAmberBalance(address: key1) { amberBalance, amberError in
            balance = amberBalance
            error = amberError
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(balance, "Balance needs to be non-nil")
        XCTAssertNil(error, "Error needs to be nil")
    }

    func testSendAmber() {
        var success: String?
        var error: BlockchainAPIError?
        let expectation = self.expectation(description: "SendAmber")
        let amberToSend = AmberUnits.micro.rawValue
        self.service.send(amount: amberToSend, to: key2, from: key1) { amberSuccess, amberError in
            success = amberSuccess
            error = amberError
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotNil(success, "Success String needs to be non-nil")
        XCTAssertNil(error, "Error needs to be nil")
    }
}
