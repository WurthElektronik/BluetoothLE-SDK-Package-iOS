//
//  MultiColorDriverBleDeviceManager,swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 09.07.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


/// Bluetooth device manager implementation. Used to enumarate and handel MultiColor LED driver bluetooth devices.
@available(iOS 10.0, *)
open class MultiColorDriverBleDeviceManager : AmberBleDeviceManager {
    
     // MARK: Shared static
    
    /// Object factory to create new sharad manager instance.
    ///
    /// - Remark: Should be called only once at application startup.
    ///           Uses **MultiColorDriverBleDeviceManager** class.
    /// - Returns: New bluetooth device manager instance.
    open override class func makeSharedManager() -> BleDeviceManager {
        return MultiColorDriverBleDeviceManager()
    }
    
    /// Retrieve the global sharad bluetooth device manager instance.
    ///
    /// - Remark: Should be reimplemented in derivered class.
    ///           Uses **MultiColorDriverBleDeviceManager** class.
    open override class var shared : MultiColorDriverBleDeviceManager {
        get {
            return sharedManager(withType: MultiColorDriverBleDeviceManager.self)
        }
    }
    
    
    // MARK: Class implementation
    
    /// Associated device class type.
    ///
    /// A derived class should overwrite this field to return the desired device class type wich it handles.
    ///
    /// - Remark: Uses **MultiColorDriverBleDevice** class.
    open override var deviceClass: BleDevice.Type {
        get {
            return MultiColorDriverBleDevice.self
        }
    }
}
