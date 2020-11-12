//
//  UUIDAppExtension.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 18.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation


extension UUID {
    
    /// Retrives UUID as byte array.
    public var bytes : [UInt8] {
        get {
            var tmp = self.uuid
            return [UInt8](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
        }
    }
    
    /// Retrives short UUID hexadecimal string (includes 6 bytes).
    public var uuidShortString : String {
        get {
            return self.uuidShortString(withSeparator: ":", 10)
        }
    }
    
    /// Converts UUID to hexadecimal formated string.
    ///
    /// - Parameters:
    ///   - separator: Seperator string to use between bytes.
    ///   - start: Start offset in bytes.
    /// - Returns: Formated hexadecimal string.
    public func uuidShortString(withSeparator separator: String, _ start: Int) -> String {
        return self.bytes[start...].map{ String(format: "%02X", $0) }.joined(separator: separator)
    }
}
