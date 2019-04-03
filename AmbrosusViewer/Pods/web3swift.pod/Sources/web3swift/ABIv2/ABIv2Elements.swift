//
//  ABIElements.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

extension ABIv2 {
    /// Function input parameter
    public struct Input: Decodable {
        var name: String?
        var type: String
        var indexed: Bool?
        var components: [Input]?
    }
    
    /// Function output parameter
    public struct Output: Decodable {
        var name: String?
        var type: String
        var components: [Output]?
    }
    
    /// Function
    public struct Record: Decodable {
        var name: String?
        var type: String?
        var payable: Bool?
        var constant: Bool?
        var stateMutability: String?
        var inputs: [ABIv2.Input]?
        var outputs: [ABIv2.Output]?
        var anonymous: Bool?
    }
    
    /// Abi Element
    public enum Element {
        /// Array size
        public enum ArraySize { // bytes for convenience
            /// Fixed size array or data
            case staticSize(UInt64)
            /// Dynamic size for dynamic arrays or data
            case dynamicSize
            /// Any other type
            case notArray
        }
        
        /// Function type
        case function(Function)
        /// Constructor
        case constructor(Constructor)
        /// Fallback
        case fallback(Fallback)
        /// Event
        case event(Event)
        
        /// Input or output type
        public struct InOut {
            let name: String
            let type: ParameterType
        }
        
        /// Function type
        public struct Function {
            let name: String?
            let inputs: [InOut]
            let outputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        /// Constructor type
        public struct Constructor {
            let inputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        /// Fallback type
        public struct Fallback {
            let constant: Bool
            let payable: Bool
        }
        
        /// Event type
        public struct Event {
            let name: String
            let inputs: [Input]
            let anonymous: Bool

            struct Input {
                let name: String
                let type: ParameterType
                let indexed: Bool
            }
        }
    }
}

extension ABIv2.Element {
    func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case let .constructor(constructor):
            guard parameters.count == constructor.inputs.count else { return nil }
            guard let data = ABIv2Encoder.encode(types: constructor.inputs, values: parameters) else { return nil }
            return data
        case .event:
            return nil
        case .fallback:
            return nil
        case let .function(function):
            guard parameters.count == function.inputs.count else { return nil }
            let signature = function.methodEncoding
            guard let data = ABIv2Encoder.encode(types: function.inputs, values: parameters) else { return nil }
            return signature + data
        }
    }
}

extension ABIv2.Element {
    func decodeReturnData(_ data: Data) -> [String: Any]? {
        switch self {
        case .constructor:
            return nil
        case .event:
            return nil
        case .fallback:
            return nil
        case let .function(function):
            if data.count == 0 && function.outputs.count == 1 {
                let name = "0"
                let value = function.outputs[0].type.emptyValue
                var returnArray = [String: Any]()
                returnArray[name] = value
                if function.outputs[0].name != "" {
                    returnArray[function.outputs[0].name] = value
                }
                return returnArray
            }

            guard function.outputs.count * 32 <= data.count else { return nil }
            var returnArray = [String: Any]()
            var i = 0
            guard let values = ABIv2Decoder.decode(types: function.outputs, data: data) else { return nil }
            for output in function.outputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if output.name != "" {
                    returnArray[output.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }

    func decodeInputData(_ rawData: Data) -> [String: Any]? {
        var data = rawData
        var sig: Data?
        switch rawData.count % 32 {
        case 0:
            break
        case 4:
            sig = rawData[0 ..< 4]
            data = Data(rawData[4 ..< rawData.count])
        default:
            return nil
        }
        switch self {
        case let .constructor(function):
            if data.count == 0 && function.inputs.count == 1 {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String: Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }

            guard function.inputs.count * 32 <= data.count else { return nil }
            var returnArray = [String: Any]()
            var i = 0
            guard let values = ABIv2Decoder.decode(types: function.inputs, data: data) else { return nil }
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        case .event:
            return nil
        case .fallback:
            return nil
        case let .function(function):
            if sig != nil && sig != function.methodEncoding {
                return nil
            }
            if data.count == 0 && function.inputs.count == 1 {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String: Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }

            guard function.inputs.count * 32 <= data.count else { return nil }
            var returnArray = [String: Any]()
            var i = 0
            guard let values = ABIv2Decoder.decode(types: function.inputs, data: data) else { return nil }
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
}

extension ABIv2.Element.Event {
    func decodeReturnedLogs(_ eventLog: EventLog) -> [String: Any]? {
        guard let eventContent = ABIv2Decoder.decodeLog(event: self, eventLog: eventLog) else { return nil }
        return eventContent
    }
}
