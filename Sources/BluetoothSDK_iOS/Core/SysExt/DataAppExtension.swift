//
//  DataAppExtension.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 09.07.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

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
