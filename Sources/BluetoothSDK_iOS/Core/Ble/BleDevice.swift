//
//  BleDevice.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


extension Notification.Name {
    
    /// Bluetooth device broadcast notification center name for 'deviceDidUpdate'.
    public static let bleDeviceDidUpdate = Notification.Name("notificationBleDeviceDidUpdate")
    
    /// Bluetooth device broadcast notification center name for 'deviceDidTimeoutAdvertisement'.
    public static let bleDeviceDidTimeoutAdvertisement = Notification.Name("notificationBleDeviceDidTimeoutAdvertisement");
}


/// Bluetooth device settings delegate protocol. Used to store custom device informations.
public protocol BleDeviceSettingsDelegate {
    
    /// Tries to retrive custom property values for the specified device.
    ///
    /// - Parameters:
    ///   - id: Device identifier.
    ///   - prop: Property key to retrive.
    /// - Returns: Value for the property value if any, else nil.
    func getDeviceProperty(for id: String, _ prop: String) -> Any?
    
    /// Tries to stores a custom property value for the specified device.
    ///
    /// - Parameters:
    ///   - id: Device identifier.
    ///   - prop: Property key to store.
    ///   - value: new value to set.
    func setDeviceProperty(for id: String, _ prop: String, _ value: Any?)
}


extension BleDeviceSettingsDelegate {
    
    /// Tries to retrive custom property values for the specified device and converts to specified type.
    ///
    /// - Parameters:
    ///   - id: Device identifier.
    ///   - prop: Property key to retrive.
    ///   - type: Type of target value
    /// - Returns: Value for the property value if any, else nil
    public func getDeviceProperty<T>(for id: String, _ prop: String, _ type: T) -> T? {
        return self.getDeviceProperty(for: id, prop) as? T
    }
    
    /// Tries to stores a custom property value of given type for the specified device.
    ///
    /// - Parameters:
    ///   - id: Device identifier.
    ///   - prop: Property key to store.
    ///   - value: new value to set.
    public func setDeviceProperty<T>(for id: String, _ prop: String, _ value: T?) {
        self.setDeviceProperty(for: id, prop, value as Any?)
    }
}


/// Bluetooth device delegate protocol. Used to notify bluetooth device instances about state changes.
public protocol BleDeviceDelegate : NSObjectProtocol {
    
    /// Callback notification function wich is called when a device succesfully connects.
    func didConnect()
    
    /// Callback notification function wich is called when a device disconnects.
    func didDisconnect()
    
    /// Callback notification function wich is called when the device faisl to connect.
    func didFailToConnect()
}


/// Abstract bluetooth device class. Should be reimplemented in derviered class.
@available(iOS 10.0, *)
open class BleDevice : NSObject, CBPeripheralDelegate, BleDeviceDelegate {

    // MARK: Shared static
    
    /// Object factory methode to create bluetooth interaction instances.
    ///
    /// - Parameter peripheral: Associated bluetooth peripheral instance.
    /// - Returns: Bluetooth device instance.
    public class func make(withPeripheral peripheral: CBPeripheral) -> BleDevice {
        return BleDevice(withPeripheral: peripheral)
    }
    
    /// Associated service uuid list, wich can be handled by this device class, if any, else nil.
    public class var serviceUUIDs: [CBUUID]? {
        get {
            return nil
        }
    }
    
    /// Associated settings delgeate. Used to store and retrive custom device properties.
    public static var settingsDelegate: BleDeviceSettingsDelegate? = nil
    
    /// Custom device property key value for 'CustomName'.
    public static let kSettingsCustomNameKey = "CustomName"
    
    
    // MARK: Class implementation
    
    /// Associated bluetooth device manager instance.
    open weak var manager : BleDeviceManager? = nil
    
    /// Associated broadcast notification center
    public var notificationCenter: NotificationCenter? {
        get {
            return self.manager?.notificationCenter ?? NotificationCenter.default
        }
    }
    
    /// Advertisement timeout field [ms] (default = 5.0)
    public var advertisementTimeout: TimeInterval = 5.0
    
    /// Associated bluetooth peripheral instance
    public private(set) var peripheral: CBPeripheral?
    
    /// Device identifier. Reported by the os.
    open var identifier : UUID {
        get {
            return self.peripheral!.identifier
        }
    }
    
    /// Hexadecimal device identifier string.
    public var uuidShortString : String {
        get {
            return self.identifier.uuidShortString
        }
    }
    
    /// Associated device name if any, else short device identifier stirng.
    public var name : String {
        get {
            return self.peripheral?.name ?? self.uuidShortString
        }
    }
    
    /// Retrieves if a associated device name is available.
    public var hasName : Bool {
        get {
            return self.peripheral?.name != nil
        }
    }
    
    /// Associated custom device name.
    public var customName : String {
        get {
            return BleDevice.settingsDelegate?.getDeviceProperty(for: self.uuidShortString, BleDevice.kSettingsCustomNameKey, String()) ?? self.name
        }
        set(newName) {
            BleDevice.settingsDelegate?.setDeviceProperty(for: self.uuidShortString, BleDevice.kSettingsCustomNameKey, newName)
        }
    }
    
    /// Retrieves if a associated custom device name is available.
    public var hasCustomName : Bool {
        get {
            return BleDevice.settingsDelegate?.getDeviceProperty(for: self.uuidShortString, BleDevice.kSettingsCustomNameKey) != nil
        }
    }
    
    /// Current device state
    open var state : CBPeripheralState {
        get {
            return self.peripheral?.state ?? .disconnected
        }
    }

    /// Retrieves connection state.
    open var isConnected : Bool {
        get {
            return self.state == .connected
        }
    }
    
    /// Determinates if the device should automatically reconect.
    public var shouldReconnect : Bool {
        get {
            if let manager = self.manager {
                return manager.selectedDevices.contains(self.identifier)
            }
   
            return false
        }
        set(value) {
            if let manager = self.manager {
                let identifier = self.identifier
                let indexOf = manager.selectedDevices.firstIndex(of: identifier)
                
                if let index = indexOf {
                    manager.selectedDevices.remove(at: index)
                }
                
                if (value) {
                   manager.selectedDevices.append(identifier)
                }  
            }
        }
    }
    
    
    /// Determinates if current device instance is either a demo device or not.
    public var isDemoDevice : Bool {
        get {
            return self.peripheral == nil
        }
    }
    
    /// Advertisement timeout timer instance. Fires events if device has been unavailable for given time.
    private var advertisementTimeoutTimer : Timer? = nil
    
    /// Default constructor.
    public override init() {
    }
    
    /// Builds the object associated with the given peripheral isntance.
    ///
    /// - Parameter peripheral: Associated bluetooth peripheral instance.
    required public init(withPeripheral peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral?.delegate = self
    }
    
    /// Restarts advertisement timer.
    public func retriggerAdvertisementTimeoutTimer() {
        self.advertisementTimeoutTimer?.invalidate()
        self.advertisementTimeoutTimer = Timer.scheduledTimer(timeInterval: self.advertisementTimeout, target: self,
                                                              selector: #selector(didAdvertisementTimeout), userInfo: nil, repeats: false)
    }

    /// Advertisement timer callback function. Fires notification center message.
    ///
    /// Notification delegated by the notification center can be used to trigger custom actions anywhere in the application.
    @objc public func didAdvertisementTimeout() {
        self.advertisementTimeoutTimer?.invalidate()
        self.advertisementTimeoutTimer = nil
        
        self.notificationCenter?.post(name: .bleDeviceDidTimeoutAdvertisement, object: self)
    }
    
    
    // MARK: BleDeviceDelegate
    
    public func didConnect() {
        // terminate advertisement timer
        // we are connected and want not to trigger anymore
        self.advertisementTimeoutTimer?.invalidate()
        self.advertisementTimeoutTimer = nil
    }
    
    public func didDisconnect() {
    }
    
    public func didFailToConnect() {
    }
}
