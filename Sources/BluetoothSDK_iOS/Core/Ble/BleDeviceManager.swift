//
//  BleDeviceManager.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import os.log


/// Bluetooth device manager protocol. Used to notify delegate about device state changes.
@available(iOS 10.0, *)
public protocol BleDeviceManagerDelegate : NSObjectProtocol {
    
    /// Callback wich is called when a device has been discovered.
    ///
    /// - Parameters:
    ///   - manager: Associated bluetooth device manager instance.
    ///   - device: Reported bluetooth device instance.
    func deviceManager(_ manager: BleDeviceManager, didDiscoverDevice device: BleDevice)
    
    /// Callback wich is called when a device has been connected.
    ///
    /// - Parameters:
    ///   - manager: Associated bluetooth device manager instance.
    ///   - device: Reported bluetooth device instance.
    func deviceManager(_ manager: BleDeviceManager, didConnectToDevice device: BleDevice)
    
    /// Callback wich is called when a device has been disconnected.
    ///
    /// - Parameters:
    ///   - manager: Associated bluetooth device manager instance.
    ///   - device: Reported bluetooth device instance.
    func deviceManager(_ manager: BleDeviceManager, didDisconnectFromDevice device: BleDevice)
    
    /// Callback wich is called when a device has been failed to connect.
    ///
    /// - Parameters:
    ///   - manager: Associated bluetooth device manager instance.
    ///   - device: Reported bluetooth device instance.
    func deviceManager(_ manager: BleDeviceManager, didDidFailToConnectToDevice device: BleDevice)
}


@available(iOS 10.0, *)
extension BleDeviceManagerDelegate {
    
    public func deviceManager(_ manager: BleDeviceManager, didDiscoverDevice device: BleDevice){
    }
    
    public func deviceManager(_ manager: BleDeviceManager, didConnectToDevice device: BleDevice){
    }
    
    public func deviceManager(_ manager: BleDeviceManager, didDisconnectFromDevice device: BleDevice){
    }
    
    public func deviceManager(_ manager: BleDeviceManager, didDidFailToConnectToDevice device: BleDevice) {
    }
}


extension Notification.Name {
    
    /// Bluetooth device manager broadcast notification center name for 'deviceManagerDidDiscoverDevice'.
    public static let bleDeviceManagerDidDiscoverDevice = Notification.Name("notificationBleDeviceManagerDidDiscoverDevice")
    
    /// Bluetooth device manager broadcast notification center name for 'deviceManagerDidUpdateDevice'.
    public static let bleDeviceManagerDidUpdateDevice = Notification.Name("notificationBleDeviceManagerDidUpdateDevice")
    
    /// Bluetooth device manager broadcast notification center name for 'deeviceManagerDidRemoveDevice"'.
    public static let bleDeviceManagerDidRemoveDevice = Notification.Name("notificationBleDeviceManagerDidRemoveDevice")
    
    /// Bluetooth device manager broadcast notification center name for 'deleDeviceManagerDidConnect'.
    public static let bleDeviceManagerDidConnect = Notification.Name("notificationBleDeviceManagerDidConnect")
    
    /// Bluetooth device manager broadcast notification center name for 'deeviceManagerDidDisconnect'.
    public static let bleDeviceManagerDidDisconnect = Notification.Name("notificationBleDeviceManagerDidDisconnect")
    
    /// Bluetooth device manager broadcast notification center name for 'deviceManagerDidFailToConnect"'.
    public static let bleDeviceManagerDidFailToConnect = Notification.Name("notificationBleDeviceManagerDidFailToConnect")
    
    /// Bluetooth device manager broadcast notification center name for 'deviceManagerDidUpdateSelectedDevice'.
    public static let bleDeviceManagerDidUpdateSelectedDevice = Notification.Name("notificationBleDeviceManagerDidUpdateSelectedDevice")
}


/// Bluetooth device manager base implementation. Used to enumarate avaialble bluetooth devices.
@available(iOS 10.0, *)
open class BleDeviceManager : NSObject, CBCentralManagerDelegate {
    
    // MARK: Shared static
    
    /// Bluetooth device manager broadcast notification key name for 'device' field.
    public static let kNotificationKeyDevice = "device"
    
    /// Bluetooth device manager broadcast notification key name for 'index' field.
    public static let kNotificationKeyIndex = "index"
    
    /// Bluetooth device manager broadcast notification key name for 'error' field.
    public static let kNotificationKeyError = "error"
    
    /// Global sharad bluetooth device manager instance.
    private static var _sharedManager: BleDeviceManager? = nil
    
    /// Object factory to create new sharad manager instance.
    ///
    /// - Remark: Should be called only once at application startup.
    /// - Returns: New bluetooth device manager instance.
    open class func makeSharedManager() -> BleDeviceManager {
        return BleDeviceManager()
    }

    /// Tries to retrieve the global sharad bluetooth device manager instance as specified type.
    ///
    ///
    /// - Parameter withType: Target type of the device manager instance.
    /// - Returns: Current bluetooth device manager instance as specified type, else throws an exception.
    public static func sharedManager<T: BleDeviceManager>(withType _: T.Type) -> T {
        if _sharedManager == nil {
            _sharedManager = makeSharedManager()
        }
        return _sharedManager as! T
    }
    
    /// Retrieve the global sharad bluetooth device manager instance.
    ///
    /// - Remark: Should be reimplemented in derivered class.
    open class var shared : BleDeviceManager {
        get {
            return sharedManager(withType: BleDeviceManager.self)
        }
    }
    
    
    // MARK: Members
    
    /// Default low level bluetooth central manager instance.
    private lazy var central: CBCentralManager = CBCentralManager.init(delegate: self, queue: nil)
    
    /// Shadow field to determinate if the managar should automatically enable scanning if bluetooth is enabled.
    private var shouldScan : Bool = false
    
    /// Determinates or sets the bluetooth scanning state.
    ///
    /// The user application should set this field according to if it wants to scan for devices or not.
    public var isScanning : Bool {
        get {
            return central.isScanning
        }
        set (scanning) {
            self.shouldScan = scanning
            
            if (self.central.state == CBManagerState.poweredOn) {
                if (scanning) {
                    let serviceUUIDs: [CBUUID] = self.deviceClass.serviceUUIDs!

                    self.central.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                }
                else {
                    self.central.stopScan()
                }
            }
        }
    }
    
    
    /// Associated device class type.
    ///
    /// A derived class should overwrite this field to return the desired device class type wich it handles.
    open var deviceClass: BleDevice.Type {
        get {
            return BleDevice.self
        }
    }
    
    /// Determinates the maximum number of selectable devices.
    public var maximumNumberOfSelectedDevices : UInt = 1
    
    /// Holds the associated notification center instance.
    public weak var notificationCenter: NotificationCenter? = NotificationCenter.default
    
    /// Holds the associated bluetooth device manager delegate.
    public weak var delegate : BleDeviceManagerDelegate? = nil
    
    /// List of current known, visible and connected deivces
    open var devices : [BleDevice] = []
    
    /// Retrieves filtered device list of current connected devices.
    public var connectedDevices : [BleDevice] {
        get {
            return self.devices.filter({ $0.isConnected })
        }
    }
    
    /// Number of devices currently in the internal list. See devices field.
    public var deviceCount : Int {
        get {
            return devices.count
        }
    }
    
    /// Number of demo devices in the internal list.
    public private(set) var demoDeviceCount : UInt = 0
    
    /// List of uuids marked as selected for auto connection.
    public var selectedDevices : [UUID] = []
    
    
    /// Default consturctor
    required public override init() {
        super.init()
    }
    
    
    /// Search for the assoiciated bluetooth device identified by given peripheral instance.
    ///
    /// - Parameters:
    ///   - peripheral: Identifing reference peripheral instance.
    ///   - shouldConnect: Determinates if device should automatic connect if found.
    /// - Returns: Associated bluetooth device instance if found, else nil.
    public func findDevice(wherePeripheral peripheral: CBPeripheral, _ shouldConnect: Bool = true) -> BleDevice? {
        
        if let device = self.devices.first(where: { $0.identifier == peripheral.identifier }) {
            if shouldConnect {
                self.connectToDeviceWhenSelected(device)
            }
            return device
        }
        
        return nil
    }
    
    /// DescriptionSearch for the assoiciated bluetooth device with given uuid.
    ///
    /// - Parameter identifier: Reference uuid.
    /// - Returns: Associated bluetooth device instance if found, else nil.
    public func findDevice(withIdentifier identifier: UUID) -> BleDevice? {
        return self.devices.first(where: { $0.identifier == identifier })
    }
    
    /// Adds several demo device to the internal device list.
    ///
    /// - Remark: This function must be called at the very beginning of the application start.
    /// - Parameter devices: List of demo device instances.
    public func addDemoDevices(_ devices: [BleDevice]) {
        for device in devices {
            device.manager = self
            self.devices.append(device)
        }
        
        self.demoDeviceCount = UInt(devices.count)
    }
    
    /// Add new discovered device to the internal list.
    ///
    /// - Parameter peripheral: Discovered peripheral instance.
    /// - Returns: New created associated bluetooth device instance.
    public func addDevice(forPeripheral peripheral: CBPeripheral) -> BleDevice {
        
        let device = self.deviceClass.make(withPeripheral: peripheral)
        device.manager = self
        
        self.notificationCenter?.addObserver(self, selector: #selector(deviceDidTimeout), name: .bleDeviceDidTimeoutAdvertisement, object: device)
        
        self.devices.append(device)
 
        return device;
    }
    
    /// Forces a connection to the give bluetooth device instance.
    ///
    /// - Remark: An event is fired if the device state will be changed.
    /// - Parameter device: Bluetotoh device instance.
    public func connectToDeviceWhenSelected(_ device: BleDevice)
    {
        if !device.isConnected && device.shouldReconnect {
            self.connect(toDevice: device)
        }
    }
    
    /// Removes a device from the internal list identified by the index.
    ///
    /// - Parameter index: List index of the device object to be removed.
    public func removeDevice(at index:Int) {
        
        guard let device = self.devices[safe: index] else {
            return
        }
    
        if device.state == .connected {
            self.disconnect(fromDevice: device)
        }
        
        self.devices.remove(at: index)
        
         self.notificationCenter?.post(name: .bleDeviceManagerDidRemoveDevice, object: self, userInfo: self.notificationUserInfo(forDevice: device))
    }
    
    /// Removes a device from the internal list identified by given instance.
    ///
    /// - Parameter device: Instance of the device object to be removed
    public func removeDevice(_ device: BleDevice) {
        guard let index = self.devices.firstIndex(of: device) else {
            return
        }
        
        self.removeDevice(at: index)
    }
    
    /// Remove all devices from the internal list except demo devices.
    public func clearDevices() {
        
        for (index, _) in self.devices.enumerated().reversed() {
            guard index > self.demoDeviceCount else {
                return
            }
            
            self.removeDevice(at: index)
        }
    }
    
    /// Creates a notification user information dictonary wich can be attached to several notifications.
    ///
    /// - Parameters:
    ///   - peripheral: Reference bluetooth peripheral.
    ///   - error: Error information instance. Can be nil if none.
    /// - Returns: Dictonary
    public func notificationUserInfo(forPeripheral peripheral: CBPeripheral, _ error: Error? = nil) -> [AnyHashable: Any] {
        return self.notificationUserInfo(forDevice: self.findDevice(wherePeripheral: peripheral, false)!, error)
    }
    
    /// Creates a notification user information dictonary wich can be attached to several notifications.
    ///
    /// - Parameters:
    ///   - device: Reference bluetotoh device.
    ///   - error: Error information instance. Can be nil if none.
    /// - Returns: Dictonary
    public func notificationUserInfo(forDevice device: BleDevice, _ error: Error? = nil) -> [AnyHashable: Any] {
        var dict = Dictionary<String, Any?>(minimumCapacity: 3)
      
        dict[BleDeviceManager.kNotificationKeyDevice] = device
        dict[BleDeviceManager.kNotificationKeyIndex] = self.devices.firstIndex(of: device)
        
        if let _error = error {
            dict[BleDeviceManager.kNotificationKeyError] = _error
        }
        
        return dict as [AnyHashable: Any]
    }
    
    /// Tries to connect to given device instance.
    ///
    /// - Parameter device: Target bluetotoh device instance.
    public func connect(toDevice device: BleDevice) {
        if self.connectedDevices.contains(device) {
            return
        }
        
        guard device.state == .disconnected else {
            return
        }
        
        device.shouldReconnect = true
        
        self.checkAndDisconnectIfLimitReached()
        
        os_log_ble("BleDeviceManager.connect: %@", type: .info, device.name)
        
        if let peripheral = device.peripheral {
            self.central.connect(peripheral, options: [
                CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                CBConnectPeripheralOptionNotifyOnNotificationKey: true ])
        }
        else if device.isDemoDevice {
            device.didConnect()
            self.delegate?.deviceManager(self, didConnectToDevice: device)
            self.notificationCenter?.post(name: .bleDeviceManagerDidConnect, object: self, userInfo: self.notificationUserInfo(forDevice: device))
        }
        else {
            os_log_ble("BleDeviceManager.connect: invalid device %@", type: .error, device.name)
        }
    }
    
    /// Tries to disconnect from given device instance.
    ///
    /// - Parameter device: Target bluetotoh device instance.
    public func disconnect(fromDevice device: BleDevice) {
        device.shouldReconnect = false
        
        guard device.state == .connected else {
            self.removeDevice(device)
            return
        }
        
        os_log_ble("BleDeviceManager.disconnect: %@", type: .info, device.name)
        
        if let peripheral = device.peripheral {
            self.central.cancelPeripheralConnection(peripheral)
        }
        else if device.isDemoDevice {
            device.didDisconnect()
            self.delegate?.deviceManager(self, didDisconnectFromDevice: device)
            self.notificationCenter?.post(name: .bleDeviceManagerDidDisconnect, object: self, userInfo: self.notificationUserInfo(forDevice: device))
        }
        else {
            os_log_ble("BleDeviceManager.disconnect: invalid device %@", type: .error, device.name)
        }
    }
    
    /// Tries to connect to all known devices.
    public func connectAll() {
        for (_, device) in self.devices.enumerated() {
            self.connect(toDevice: device)
        }
    }
    
    /// Tries to disconnect from all known devices.
    public func disconnectAll() {
        for (_, device) in self.devices.enumerated().reversed() {
            self.disconnect(fromDevice: device)
        }
    }
    
    /// Helper function wich disocnnects and deselects bluetotoh devices if the maximum number of selectable devices is reached.
    private func checkAndDisconnectIfLimitReached() {
        while self.selectedDevices.count > self.maximumNumberOfSelectedDevices {
            let identifier = self.selectedDevices.removeFirst()
            if let foundDevice = self.findDevice(withIdentifier: identifier) {
                self.disconnect(fromDevice: foundDevice)
            }
        }
    }
    
    // MARK: Notifications
    
    /// Broadcast callback function wich removes the given device from the internal list if it timeouts.
    ///
    /// - Parameter notification: Notification identifier.
    @objc public func deviceDidTimeout(withAdvertisementNotification notification: NSNotification) {
        if let device = notification.object as! BleDevice? {
            if !device.isConnected && !device.shouldReconnect {
                os_log_ble("BleDeviceManager.deviceDidTimeout: remove %@", type: .info, device)
                self.removeDevice(device)
            }
        }
    }
    
    // MARK: CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central == self.central else {
            os_log_ble("BleDeviceManager.centralManagerDidUpdateState: unexpected central instance reference", type: .error)
            return
        }
        
        os_log_ble("BleDeviceManager.centralManagerDidUpdateState: %@ (%d)", type: .info, central, central.state.rawValue)
        
        if (!self.isScanning) && (self.shouldScan) {
            self.isScanning = true
        }
        else if (central.state == CBManagerState.poweredOff) {
            self.clearDevices()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard central == self.central else {
            os_log_ble("BleDeviceManager.centralManagerDidDiscover: unexpected central instance reference", type: .error)
            return
        }
        
        let found : Bool = true
        
        // TODO: optional filter device here
        
        if found {
            var device : BleDevice? = self.findDevice(wherePeripheral: peripheral)
            
            if device == nil {
                device = self.addDevice(forPeripheral: peripheral)
                
                self.delegate?.deviceManager(self, didDiscoverDevice: device!)
            
                self.notificationCenter?.post(name: .bleDeviceManagerDidDiscoverDevice, object: self, userInfo: self.notificationUserInfo(forDevice: device!))
            }
            else {
                self.notificationCenter?.post(name: .bleDeviceManagerDidUpdateDevice, object: self, userInfo: self.notificationUserInfo(forDevice: device!))
            }
            
            device?.retriggerAdvertisementTimeoutTimer()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard central == self.central else {
            os_log_ble("BleDeviceManager.centralManagerDidConnect: unexpected central instance reference", type: .error)
            return
        }
        
        os_log_ble("BleDeviceManager.centralManagerDidConnectPeripheral: %@", type: .info, peripheral.name ?? "na")
        
        if let device = self.findDevice(wherePeripheral: peripheral) {
            if !device.shouldReconnect {
                device.shouldReconnect = true
                self.checkAndDisconnectIfLimitReached()
            }
            device.didConnect()
            self.delegate?.deviceManager(self, didConnectToDevice: device)
            self.notificationCenter?.post(name: .bleDeviceManagerDidConnect, object: self, userInfo: self.notificationUserInfo(forDevice: device))
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard central == self.central else {
            os_log_ble("BleDeviceManager.centralManagerDidDisconnectPeripheral: unexpected central instance reference", type: .error)
            return
        }
        
        os_log_ble("BleDeviceManager.centralManagerDidDisconnectPeripheral: %@", type: .info, peripheral.name ?? "na")
        
        if let device = self.findDevice(wherePeripheral: peripheral, false) {
            device.didDisconnect()
            self.delegate?.deviceManager(self, didDisconnectFromDevice: device)
            self.notificationCenter?.post(name: .bleDeviceManagerDidDisconnect, object: self, userInfo: self.notificationUserInfo(forDevice: device, error))
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard central == self.central else {
            os_log_ble("BleDeviceManager.centralManagerDidFailToConnect : unexpected central instance reference", type: .error)
            return
        }
        
        os_log_ble("BleDeviceManager.centralManagerDidFailToConnect: %@", type: .debug, peripheral.name ?? "na")
        
        if let device = self.findDevice(wherePeripheral: peripheral, false) {
            device.didFailToConnect()
            self.delegate?.deviceManager(self, didDidFailToConnectToDevice: device)
            self.notificationCenter?.post(name: .bleDeviceManagerDidFailToConnect, object: self, userInfo: self.notificationUserInfo(forDevice: device, error))
        }
    }
}
