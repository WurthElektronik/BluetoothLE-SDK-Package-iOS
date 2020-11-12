// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

extension Data {
    
    /// Retrives hexadecimal string representation of the Data object.
    ///
    /// - Parameter sep: Seperator string to use between bytes.
    /// - Returns: Formated hexadecimal string.
    public func hexDescription(_ sep: String = "") -> String {
        return self.map() { String(format: "%02x", $0) }.joined(separator: sep)
    }
}
