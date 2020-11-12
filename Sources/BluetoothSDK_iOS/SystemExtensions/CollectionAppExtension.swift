// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

extension Collection {
    
    // MARK: subscript(safe:)
    
    /// Tries to get the element of the specified elemnt index offset.
    ///
    /// - Remark: Does not throw exceptions, if element is out of range.
    /// - Parameter index: Element index.
    /// - Returns: Element at specified index if any, else nil.
    public subscript (safe index: Index) -> Element? {
        guard (index >= self.startIndex) && (index < self.endIndex) else {
            return nil
        }
        
        return self[index]
    }
    
    // MARK: subscript(zeroIndexed:)
    
    /// Retrives element at specified index.
    ///
    /// - Parameter index: Element index; independently from slice range the first element index starts always with 0.
    /// - Returns: Element at specified index if any, else throws exception.
    public subscript (zeroIndexed index: Int) -> Element {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
