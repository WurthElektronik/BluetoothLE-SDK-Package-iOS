// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

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

    open override func shouldDiscover(rssi RSSI: NSNumber) -> Bool {
        guard let minimumRSSI = deviceClass.minimumRSSI else {
            return true
        }
        return RSSI.intValue >= minimumRSSI
    }

    open override func shouldRemoveFromDiscovery(badRSSICount: Int) -> Bool {
        guard let maximumBadRSSICount = deviceClass.maximumBadRSSICount else {
            return false
        }
        return badRSSICount >= maximumBadRSSICount
    }
}
