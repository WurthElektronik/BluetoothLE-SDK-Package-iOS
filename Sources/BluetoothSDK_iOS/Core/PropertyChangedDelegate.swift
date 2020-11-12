//
//  PropertyChangedDelegate.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 10.07.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation


/// Support protocol to signaling class property changes.
public protocol PropertyChangedDelegate : NSObjectProtocol {
    
    /// Did set callback function.
    ///
    /// - Parameters:
    ///   - sender: Object wich called this function.
    ///   - name: Property name wich changed.
    ///   - oldValue: Previous value of the property.
    ///   - newValue: Current value of the property.
    func didSet(_ sender: Any, _ name: String, _ oldValue: Any?, _ newValue: Any?)
}
