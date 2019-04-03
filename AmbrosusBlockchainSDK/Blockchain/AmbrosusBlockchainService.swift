//
//  AmbrosusBlockchainService.swift
//
//  Copyright © 2019 Ambrosus Technologies GmbH. All rights reserved.
//

import web3swift
import BigInt
import PromiseKit

fileprivate extension Web3HttpProvider {

    convenience init?(_ url: URL?) {
        guard let url = url else { return nil }
        self.init(url)
    }
}

/// Denominations for Amber
///
/// - micro: One Millionth of a single Amber token
/// - milli: One Thousandth of a single Amber token
/// - cent: One Hundreth of a single Amber token
/// - one: A single Amber token
/// - ten: Ten Amber tokens
public enum AmberUnits: BigUInt {
    /// One Millionth of a single Amber token
    case micro =
    1000000000000

    /// One Thousandth of a single Amber token
    case milli =
    1000000000000000

    /// One Hundreth of a single Amber token
    case cent =
    10000000000000000

    /// A single Amber token
    case one =
    1000000000000000000

    /// Ten Amber tokens
    case ten =
    10000000000000000000
}

/// Class that encapsulates the communication with the Ambrosus blockchain.
public class AmbrosusBlockchainService: NSObject {

    private let server: String

    private var web3: Web3?
    private lazy var web3Provider = Web3HttpProvider(URL(string: server))

    /// Default instance which will be using the test net.
    /// - Important:
    /// If you want to use main net, then you have to provide a valid url to it.
    public static let defaultServerURL = "https://network.ambrosus-test.com"

    static let queue = DispatchQueue(label: "ambrosus.blockchain.networking")

    /// Construct an instance that will use the provided net address.
    /// - Important:
    /// If the address is not valid, then all bliockchain operations will fail.
    public init(server: String = defaultServerURL) {
        self.server = server
    }

    /// Kicks off the blockchain service so it can begin receiving messages
    ///
    /// - Parameters:
    ///   - seedPhrase: Set the 12 word Seed Phrase to be used when signing transactions
    ///     (optional, can be set also with setKeystore(_:) method
    ///   - didComplete: Callback to send messages as soon as the service is available
    public func start(with seedPhrase: String? = nil, didComplete: (() -> Void)? = nil) {
        AmbrosusBlockchainService.queue.async {
            if self.instantiateWebProvider() != nil {
                if let seedPhrase = seedPhrase {
                    self.setKeystore(from: seedPhrase) {
                        didComplete?()
                    }
                } else {
                    didComplete?()
                }
            }
        }
    }

    @discardableResult private func instantiateWebProvider() -> Web3? {
        guard let web3Provider = web3Provider,
        web3 == nil else {
            return web3
        }
        web3 = Web3(provider: web3Provider)
        return web3
    }

    private func getWeb3() -> Web3? {
        return web3 ?? instantiateWebProvider()
    }
    
    private func setKeystore(from mnemonics: Mnemonics, didComplete: (() -> Void)?) {
        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics),
        let web3 = getWeb3() else {
            NSLog(ErrorMessage.couldNotCreateNewKeystore)
            return
        }
        web3.keystoreManager = KeystoreManager([keystore])
        didComplete?()
    }

    public var address: Address? {
        guard let keystore = web3?.keystoreManager.bip32keystores.first else {
            return nil
        }
        return keystore.addresses.first
    }

    /// Sets the keystore, which contains the private key used to sign the transaction
    ///
    /// - Parameter phrase: The phrase used to generate the keystore
    @discardableResult public func setKeystore(from phrase: String, didComplete: (() -> Void)? = nil) -> Error? {
        guard let mnemonics = try? Mnemonics(phrase, language: AccountsGenerator.language) else {
            NSLog(ErrorMessage.cannotGenerateSeedPhrase)
            return BlockchainAPIError(error: ErrorMessage.cannotGenerateSeedPhrase)
        }
        AmbrosusBlockchainService.queue.async {
            self.setKeystore(from: mnemonics) {
                didComplete?()
            }
        }
        return nil
    }

    /// Fetch the balance of an address from the blockchain.
    ///
    /// - Parameters:
    ///   - walletAddress: The address which will be used.
    ///   - callback: Escaping function that has the following type:
    ///     `(BigUInt?, BlockchainAPIError?)->()`. It will be returning the
    ///     amount or error if something goes wrong.
    public func fetchAmberBalance(address walletAddress: String,
                            callback: @escaping(BigUInt?, BlockchainAPIError?) -> Void) {
        let address = Address(walletAddress)
        AmbrosusBlockchainService.queue.async {
            guard let web3 = self.getWeb3() else {
                DispatchQueue.main.async {
                    callback(nil, BlockchainAPIError(error: "Unable to create Web3 Instance"))
                }
                return
            }
            do {
                let balanceResult = try web3.eth.getBalance(address: address)
                DispatchQueue.main.async {
                    callback(balanceResult, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    callback(nil, BlockchainAPIError(error: error.localizedDescription))
                }
            }
        }
    }

    /// Send AMB tokens to address, from address, that's part of the keystore.
    ///
    /// - Parameters:
    ///   - amount: The amount to be sent. If it's more than available amount, the transaction will fail.
    ///   - toAddress: The address to which the amount should be transferred.
    ///   - fromAddress: The address of the owner. This is tightly coupled with the private key.
    ///   - callback: Escaping function that has the following type:
    ///     `(String?, BlockchainAPIError?)->()` It will contain the hash code
    ///     of the transaction or error, if something goes wrong.
    public func send(amount: BigUInt,
                     to toAddress: String,
                     from fromAddress: String,
                     callback: @escaping (String?, BlockchainAPIError?) -> Void ) {
        var options = Web3Options()
        options.to = Address(toAddress)
        options.from = Address(fromAddress)

        AmbrosusBlockchainService.queue.async {
            guard let web3 = self.getWeb3() else {
                callback(nil, BlockchainAPIError(error: "Unable to create Web3 Instance"))
                return
            }

            guard !web3.keystoreManager.bip32keystores.isEmpty else {
                callback(nil, BlockchainAPIError(error: "No private key available to sign transaction."))
                return
            }

            let gasPriceResult = try? web3.eth.getGasPrice()
            guard gasPriceResult != nil else {
                DispatchQueue.main.async {
                    callback(nil, BlockchainAPIError(error: "Unable to get gas price."))
                }
                return
            }
            web3.provider.attachedKeystoreManager = web3.keystoreManager
            // TODO: this might be passed in an argument in future
            options.gasPrice = gasPriceResult

            let coldWalletABI = Web3.Utils.coldWalletABI
            options.value = amount

            // TODO: error handling
            let intermediateSend = try? web3.contract(coldWalletABI, at: options.to).method(options: options)

            // TODO: error handling
            let sendResult = try? intermediateSend?.send()
            guard sendResult != nil else {
                DispatchQueue.main.async {
                    callback(nil, BlockchainAPIError(error: "Unable to transfer amount"))
                }
                return
            }

            let transactionHash = sendResult.unsafelyUnwrapped?.hash
            DispatchQueue.main.async {
                callback(transactionHash, nil)
            }
        }
    }
}

/// Specific error strcture for better error handling when communicating with the blockchain.
public struct BlockchainAPIError: Error {

    /// Property, which cotains the decription of the error.
    let error: String

    /// Default constructor.
    init() {
        error = "Unknown error"
    }

    /// Constructor which specifies the error.
    ///
    /// - Parameter error: The error specified
    init(error: String) {
        self.error = error
    }

}
