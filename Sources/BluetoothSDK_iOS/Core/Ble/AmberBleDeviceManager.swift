//
//  AmberBleDeviceManager.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


/// Bluetooth device manager implementation. Used to enumarate and handel amber bluetooth devices.
@available(iOS 10.0, *)
open class AmberBleDeviceManager : BleDeviceManager {
    
     // MARK: Shared static
    
    /// Object factory to create new sharad manager instance.
    ///
    /// - Remark: Should be called only once at application startup.
    ///           Uses **AmberBleDeviceManager** class.
    /// - Returns: New bluetooth device manager instance.
    open override class func makeSharedManager() -> BleDeviceManager {
        return AmberBleDeviceManager()
    }
    
    /// Retrieve the global sharad bluetooth device manager instance.
    ///
    /// - Remark: Should be reimplemented in derivered class.
    ///           Uses **AmberBleDeviceManager** class.
    open override class var shared : AmberBleDeviceManager {
        get {
            return sharedManager(withType: AmberBleDeviceManager.self)
        }
    }
    
    
    // MARK: Class implementation
    
    /// Associated device class type.
    ///
    /// A derived class should overwrite this field to return the desired device class type wich it handles.
    ///
    /// - Remark: Uses **AmberBleDevice** class.
    open override var deviceClass: BleDevice.Type {
        get {
            return AmberBleDevice.self
        }
    }
}
