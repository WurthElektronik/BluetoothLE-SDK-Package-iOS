// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

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
