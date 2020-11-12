// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

extension String {

    /// Retrives a CharacterSet with all valid hexadecimal Characters.
    public static var hexadecimalCharacters: CharacterSet {
        return CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
    }

    /// Determines if string is a valid hexadecimal string.
    ///
    /// - Returns: A boolean determining if string has a valid hexadecimal format.
    public func isValidHex() -> Bool {
        let value = self.replacingOccurrences(of: " ", with: "")
        guard !value.isEmpty, value.count % 2 == 0 else {
            return false
        }

        return String.hexadecimalCharacters.isSuperset(of: CharacterSet(charactersIn: value))
    }

    /// Retrives a hexadecimal string representation as a Data object.
    ///
    /// - Returns: Data representation of valid hexadecimal string.
    public func hexadecimal() -> Data? {
        let value = self.replacingOccurrences(of: " ", with: "")
        guard value.isValidHex() else {
            return nil
        }
        let length = value.count / 2
        var data = Data(capacity: length)
        for i in 0..<length {
            let j = value.index(value.startIndex, offsetBy: i*2)
            let k = value.index(j, offsetBy: 2)
            let bytes = value[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        return data
    }

    /// Creates a string combined of all input strings.
    ///
    /// - Parameters:
    ///   - strings: String values that should be combined.
    ///   - seperator: Seperator between each input string.
    /// - Returns: Combined String.
    public static func combined(strings: [String], seperator: String) -> String {
        var combinedString = ""
        for string in strings {
            if !combinedString.isEmpty && !string.isEmpty {
                combinedString += seperator
            }
            combinedString += string
        }
        return combinedString
    }
}
