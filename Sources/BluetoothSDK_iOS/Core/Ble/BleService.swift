//
//  BleService.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


/// Bluetooth service delegate class. Used to notify service about device changes and capabilities.
public protocol BleServiceDelegate : NSObjectProtocol {
    
    // MARK: Characteristic callbacks
    
    /// Did connect callback function.
    func deviceDidConnect()
    
    /// Did disconnect callback function.
    func deviceDidDisconnect()
    
    
    // MARK: Characteristic callbacks
    
    /// Callback function wich determinates if the service wants to subscribe to the given characteristic.
    ///
    /// - Parameter characteristic: Reported characteristic instance.
    /// - Returns: True if the service wants to subscibe to the given characteristic.
    func shouldSubscribe(toCharacteristic characteristic: CBCharacteristic) -> Bool
    
    /// Callback function tells the service that the given characteristic has been discovered.
    ///
    /// - Parameter characteristic: Reported characteristic instance.
    func didDiscover(_ characteristic: CBCharacteristic)
    
    /// Callback function wich will be called if a value update has been received.
    ///
    /// - Parameters:
    ///   - characteristic: Reference characteristic instance.
    ///   - error: Error description instance if any, else nil.
    func didUpdate(valueForCharacteristic characteristic: CBCharacteristic, _ error: Error?)
    
    /// Callback function wich will be called if a notifcation state change has been occured.
    ///
    /// - Parameters:
    ///   - characteristic: Reference characteristic instance.
    ///   - error: Error description instance if any, else nil.
    func didUpdate(notificationStateForCharacteristic characteristic: CBCharacteristic?, _ error: Error?)
    
    /// Callback function wich will be called if a new value has been written to the specified characteristics.
    ///
    /// - Parameters:
    ///   - characteristic: Reference characteristic instance.
    ///   - error: Error description instance if any, else nil.
    func didWrite(valueForCharacteristic characteristic: CBCharacteristic, _ error: Error?)
}


extension BleServiceDelegate {
   
    public func deviceDidConnect() {
    }
    
    public func deviceDidDisconnect() {
    }
    
    public func shouldSubscribe(toCharacteristic characteristic: CBCharacteristic) -> Bool {
        return false
    }
    
    public func didDiscover(_ characteristic: CBCharacteristic) {
    }
    
    public func didUpdate(valueForCharacteristic characteristic: CBCharacteristic, _ error: Error?) {
    }
    
    public func didUpdate(notificationStateForCharacteristic characteristic: CBCharacteristic?, _ error: Error?) {
    }
    
    public func didWrite(valueForCharacteristic characteristic: CBCharacteristic, _ error: Error?) {
    }
}


/// Abstract bluetooth service class. Should be derivered with desired service processing functionality.
@available(iOS 10.0, *)
open class BleService : NSObject, BleServiceDelegate {
    
    // MARK: Shared static
    
    /// Retrieves supported service uuids.
    ///
    /// - Remark: Should reimplemented in derivered class.
    /// - Returns: Supported bluetooth service uuids if any, else nil.
    public class func serviceUUIDs() -> [CBUUID]? {
        return nil
    }
    
    /// Retrieves supported characteristic uuids for given service uuid.
    ///
    /// - Remark: Should reimplemented in derivered class.
    /// - Parameter service: Service uuid. One of serviceUUIDs.
    /// - Returns: List of associated characteristic uuids if any, else nil.
    public class func characteristicUUIDs(forService service: CBUUID) -> [CBUUID]? {
        return nil
    }
    
    
    // MARK: Class implementation
    
    /// Associated bluetooth device instance.
    public private(set) var device : BleDevice
    
    /// Creates assocated bluetooth service instance.
    ///
    /// - Parameter device: Associated bluetooth device instance.
    public init(withDevice device: BleDevice) {
        self.device = device
        super.init()
    }
}
