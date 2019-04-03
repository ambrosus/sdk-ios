////
//  Copyright © 2018 Ambrosus Inc. All rights reserved.
//

import Foundation
import web3swift

struct ErrorMessage {
    static let defaultKeystoreNotSet = "Default Keystore has not been set"
    static let cannotGenerateSeedPhrase = "Cannot generate Seed Phrase"
    static let couldNotCreateNewKeystore = "Could not create new keystore"
    static let couldNotConstructMnemonicsFromSeedPhrase = "Could not construct mnemonics from Seed Phrase"
}

/// Generate Ambrosus Blockchain accounts using 12 word seed phrase or private key
public final class AccountsGenerator: NSObject {

    public static let shared = AccountsGenerator()

    private let defaultEntropySize = EntropySize(rawValue: 128)
    static let language = BIP39Language.english

    /// Generates a Mnemonics object from a 12 word seed phrase
    ///
    /// - Parameter phrase: The phrase in 12-word String format, words separated by a space (e.g. "rain object fire")
    /// - Returns: The Mnemonics if valid, otherwise nil
    public func mnemonics(from phrase: String) -> Mnemonics? {
        let fetchedMnemonics = try? Mnemonics(phrase, language: .english)
        return fetchedMnemonics
    }

    /// Generates a new 12-word seed phrase and returns it, if already created
    /// it will return the already created Mnemonics
    public lazy var creationSeedPhraseMnemonics: Mnemonics? = {
        guard let twelveWordEntropySize = defaultEntropySize else {
            NSLog(ErrorMessage.cannotGenerateSeedPhrase)
            return nil
        }

        let creationMnemonics = Mnemonics(entropySize: twelveWordEntropySize, language: AccountsGenerator.language)
        return creationMnemonics
    }()

    /// The generated Mnemonics in String format with words separated by spaces
    public var creationSeedPhraseWord: String? {
        return creationSeedPhraseMnemonics?.string
    }
}

extension Mnemonics {

    /// Derive the Private Key (hexadecimal String) that represents this seed phrase
    public var privateKey: PrivateKey? {
        return PrivateKey(seed())
    }
}

extension PrivateKey {

    /// Convert the private key into an array format for display to the end-user
    public var words: [String] {
        let hex = privateKey.hex(separateEvery: 4)
        let words = hex.split(separator: " ").map { String($0) }
        return words
    }

}
