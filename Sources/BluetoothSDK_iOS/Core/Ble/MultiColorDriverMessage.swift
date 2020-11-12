//
//  MultiColorDriverMessage.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 09.07.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation


/// Definition of multicolor LED driver bluetooth message.
struct MultiColorDriverMessage {
    
    // MARK: Shared static
    
    /// Definition of payload length.
    public static let kPayloadLength: UInt8 = 4
    
    /// Definition of frame length.
    public static let kLength: UInt8 = kPayloadLength + 1
    
    /// Default opcode value.
    public static let kOpCode: UInt16 = 0x0001
    
    
    /// Tries to dissambling the given data chunk into multicolor LED driver bluetooth message list.
    ///
    /// - Parameter data: Input data blob.
    /// - Returns: List of color value message objects.
    public static func make(with data:Data) -> [MultiColorDriverMessage] {
        return stride(from: 1, through: data.count, by: Int(MultiColorDriverMessage.kLength)).map(){ start in
            let end = min(start + Int(MultiColorDriverMessage.kLength), data.count + 1)
            return MultiColorDriverMessage(with: data[start..<end])
        }
    }
    
    /// Dumps given color value message objects into specified data object.
    ///
    /// - Parameters:
    ///   - messages: Input list of color value message objects.
    ///   - data: Output data object.
    /// - Returns: True on success, else false.
    public static func dump(_ messages: [MultiColorDriverMessage], to data: inout Data) -> Bool {
        for var message in messages {
            if !message.dump(adjustedTo: &data) {
                return false
            }
        }
        return true
    }
    
    /// Dumps given color value list of float type into specified data object.
    ///
    /// - Parameters:
    ///   - values: Input list of color vlaues. Considering channels index defined by array position.
    ///   - data: Output data object.
    /// - Returns: True on success, else false.
    public static func dump(withChannelValues values: [Float], to data: inout Data) -> Bool {
        let messages = values.enumerated().map() { item in
            return MultiColorDriverMessage(UInt8(item.offset), item.element)
        }
        return dump(messages, to: &data)
    }
    
    /// Dumps given color value list of Uint8 type into specified data object.
    ///
    /// - Parameters:
    ///   - values: Input list of color vlaues. Considering channels index defined by array position.
    ///   - data: Output data object.
    /// - Returns: True on success, else false.
    public static func dump(withChannelValues values: [UInt8], to data: inout Data) -> Bool {
        let messages = values.enumerated().map() { item in
            return MultiColorDriverMessage(UInt8(item.offset), item.element)
        }
        return dump(messages, to: &data)
    }
    
    
    // MARK: Class implementation
    
    /// Holds the length of the current message.
    public var length: UInt8 = MultiColorDriverMessage.kPayloadLength
    
    /// Holds the operation code of the current message.
    public var opCode: UInt16 = MultiColorDriverMessage.kOpCode
    
    /// Holds the channel identifier of the current message.
    public var channel: UInt8 = 0
    
    /// Holds the channel value of the current message.
    public var value: UInt8 = 0
    
    /// Helper field to get and set the channel value of the current message as floating number.
    public var floatValue: Float {
        get {
            return Float(self.value) / 255.0
        }
        set(newValue) {
            self.value = UInt8(floor(newValue * 255.0))
        }
    }
    
    /// Creates a new message object by given channel and given value as UInt8.
    ///
    /// - Parameters:
    ///   - channel: Channel identifier.
    ///   - value: Channel value.
    public init(_ channel: UInt8, _ value: UInt8) {
        self.channel = channel
        self.value = value
    }
    
    /// Creates a new message object by given channel and given value as floating number.
    ///
    /// - Parameters:
    ///   - channel: Channel identifier.
    ///   - value: Channel value.
    public init(_ channel: UInt8, _ value: Float) {
        self.channel = channel
        self.floatValue = value
    }
    
    /// Create message object from given data object.
    ///
    /// - Parameter data: Input data object.
    public init(with data: Data) {
        self.length = 0
        self.opCode = 0
        self.channel = 0
        self.value = 0
        
        guard data.count >= (MultiColorDriverMessage.kLength) else {
            assertionFailure("MultiColorDriverMessage.init(with): provided data to small")
            return
        }
        
        self.length = data[zeroIndexed: 0]
        guard self.length == MultiColorDriverMessage.kPayloadLength else {
            assertionFailure("MultiColorDriverMessage.init(with): only messages with length equal to \(MultiColorDriverMessage.kPayloadLength) supported")
            return
        }
        
        self.opCode = UInt16(data[zeroIndexed: 1]) | (UInt16(data[zeroIndexed: 2]) << 8)
        guard self.opCode == MultiColorDriverMessage.kOpCode else {
            assertionFailure("MultiColorDriverMessage.init(with): only opCode \(MultiColorDriverMessage.kOpCode) messages supported")
            return
        }
        
        self.channel = data[zeroIndexed: 3]
        self.value = data[zeroIndexed: 4]
    }
    
    /// Stores current message to given output data object.
    ///
    /// - Remark: Always adjusts the frame length and the operation code field to the default value.
    /// - Parameter data: Output data object.
    /// - Returns: True on success, else false.
    public mutating func dump(adjustedTo data: inout Data) -> Bool {
        self.length = MultiColorDriverMessage.kPayloadLength
        self.opCode = MultiColorDriverMessage.kOpCode
        
        return self.dump(to: &data)
    }
    
    /// Stores current message to given output data object.
    ///
    /// - Parameter data: Output data object.
    /// - Returns: True on success, else false.
    public func dump(to data: inout Data) -> Bool {
        guard self.length == MultiColorDriverMessage.kPayloadLength else {
            assertionFailure("MultiColorDriverMessage.dump(to:andAdjust): only messages with length equal to \(MultiColorDriverMessage.kLength) supported")
            return false
        }
        
        guard self.opCode == MultiColorDriverMessage.kOpCode else {
            assertionFailure("MultiColorDriverMessage.init(to:andAdjust): only opCode \(MultiColorDriverMessage.kOpCode) messages supported")
            return false
        }
        
        data.append([self.length, UInt8(self.opCode & 0xFF), UInt8((self.opCode >> 8) & 0xFF), self.channel, self.value], count: 5)
        return true
    }
}
