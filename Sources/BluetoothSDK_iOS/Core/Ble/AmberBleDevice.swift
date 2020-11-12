//
//  AmberBleDevice.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


/// Generic bluetooth device class to handle amber serial protocol service.
@available(iOS 10.0, *)
open class AmberBleDevice : BleDevice {
    
     // MARK: Shared static
    
    public override class func make(withPeripheral peripheral: CBPeripheral) -> AmberBleDevice {
        return AmberBleDevice(withPeripheral: peripheral)
    }
    
    public override class var serviceUUIDs: [CBUUID]? {
        get {
            return AmberBleService.serviceUUIDs()
        }
    }
    
    
    // MARK: Class implementation
    
    /// Holds the associated serial service instance.
    public private(set) var serialService: AmberBleService? = nil
    
    /// Default constructor.
    public override init() {
        super.init()
    }
    
    /// Creates device associated with the given peripheral.
    ///
    /// - Parameter peripheral: Reference peripheral instance.
    required public init(withPeripheral peripheral: CBPeripheral) {
        super.init(withPeripheral: peripheral)
        self.advertisementTimeout = 3.0
        self.serialService = AmberBleService(withDevice: self)
    }
    
    
    // MARK: BleDeviceDelegate
    
    public override func didConnect() {
        self.serialService?.deviceDidConnect()
    }
    
    public override func didDisconnect() {
        self.serialService?.deviceDidDisconnect()
    }
    
    public override func didFailToConnect() {
        self.didDisconnect()
    }
    
    
    // MARK: CBPeripheralDelegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral == self.peripheral else {
            os_log_ble("AmberBleDevice.didDiscoverServices: unexpected peripheral instance reference", type: .error)
            return
        }
        
        var foundService = false
        
        peripheral.services?.forEach() { service in
            if let characteristicUUIDs = AmberBleService.characteristicUUIDs(forService: service.uuid) {
                peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
                foundService = true
            }
            else {
                os_log_ble("AmberBleDevice.didDiscoverServices: unsupported service uuid %s", type: .debug, service.uuid.uuidString)
            }
        }
        
        if !foundService {
            os_log_ble("AmberBleDevice.didDiscoverServices: desired service not found", type: .error)
            
            // TODO: disconnect again?
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard peripheral == self.peripheral else {
            os_log_ble("AmberBleDevice.didDiscoverCharacteristicsFor: unexpected peripheral instance reference", type: .error)
            return
        }
        
        guard let serialService = self.serialService else {
            os_log_ble("AmberBleDevice.didDiscoverCharacteristicsFor: serialService instance is nil", type: .error)
            return
        }
        
        service.characteristics?.forEach() { characteristic in
            serialService.didDiscover(characteristic)
            if serialService.shouldSubscribe(toCharacteristic: characteristic) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        if serialService.transmitDataCharacteristic == nil {
            os_log_ble("AmberBleDevice.didDiscoverCharacteristicsFor: desired transmit characteristic not found", type: .error)
            
            // TODO: disconnect again?
        }
        
        if serialService.receiveDataCharacteristic == nil {
            os_log_ble("AmberBleDevice.didDiscoverCharacteristicsFor: desired receive characteristic not found", type: .error)
            
            // TODO: disconnect again?
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral == self.peripheral else {
            os_log_ble("AmberBleDevice.didUpdateValueFor: unexpected peripheral instance reference", type: .error)
            return
        }
        
        self.serialService?.didUpdate(valueForCharacteristic: characteristic, error)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral == self.peripheral else {
            os_log_ble("AmberBleDevice.didWriteValueFor: unexpected peripheral instance reference", type: .error)
            return
        }
        
        self.serialService?.didWrite(valueForCharacteristic: characteristic, error)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard peripheral == self.peripheral else {
            os_log_ble("AmberBleDevice.didUpdateNotificationStateFor: unexpected peripheral instance reference", type: .error)
            return
        }
        
        self.serialService?.didUpdate(notificationStateForCharacteristic: characteristic, error)
    }
}
