//
//  AmberBleService.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


/// Amber bluetotoh device service protocol. Used to notify delegate about new incoming data.
public protocol AmberBleServiceDelegate : NSObjectProtocol {
    
    func dataReceived(_ incomingData: Data)
}


/// Amber bluetooth service class. Handles incoming and outgoing data provided by the SSP like bluetooth protocol.
@available(iOS 10.0, *)
open class AmberBleService : BleService {
    
    // MARK: Shared static
    
    /// Payload header type definition for user data.
    public static let kHeaderTypeUserData = 0x01
    
    /// Associated service UUID as string.
    public static let kUartServiceUUID = "6e400001-c352-11e5-953d-0002a5d5c51b"
    
    /// Associated characteristics transmit UUID as string.
    public static let kUartServiceTransmitCharacteristicUUID = "6e400002-c352-11e5-953d-0002a5d5c51b"
    
    /// Associated characteristics receive UUID as string.
    public static let kUartServiceReceiveCharacteristicUUID = "6e400003-c352-11e5-953d-0002a5d5c51b"
    
    
    /// Associated service UUID as characteristics class.
    public static let uartServiceUUID = CBUUID(string: kUartServiceUUID)
    
     /// Associated characteristics transmit UUID characteristics class.
    public static let uartServiceTransmitCharacteristicUUID = CBUUID(string: kUartServiceTransmitCharacteristicUUID)
    
    /// Associated characteristics receive UUID characteristics class.
    public static let uartServiceReceiveCharacteristicUUID = CBUUID(string: kUartServiceReceiveCharacteristicUUID)
    
    
    /// Retrieves supported service uuids.
    ///
    /// - Remark: Should reimplemented in derivered class.
    ///           Returns **SSP (UART)** service identifier.
    /// - Returns: Supported bluetooth service uuids if any, else nil.
    public class override func serviceUUIDs() -> [CBUUID]? {
        return [uartServiceUUID]
    }
    
    /// Retrieves supported characteristic uuids for given service uuid.
    ///
    /// - Remark: Should reimplemented in derivered class.
    /// - Parameter service: Service uuid. One of serviceUUIDs.
    /// - Returns: List of associated characteristic uuids if any, else nil.
    ///            For UART service: transmit and receive characteristics uuid.
    public class override func characteristicUUIDs(forService service: CBUUID) -> [CBUUID]? {
        if service == uartServiceUUID {
            return [uartServiceTransmitCharacteristicUUID, uartServiceReceiveCharacteristicUUID]
        }

        return nil
    }
    
    
    // MARK: Class implementation
    
    /// Holds the service delegate if any.
    public weak var delegate : AmberBleServiceDelegate? = nil
    
    
    /// Associated transmit characteristics instance if any.
    public private(set) weak var transmitDataCharacteristic : CBCharacteristic?
    
    ///  Associated receive characteristics instance if any.
    public private(set) weak var receiveDataCharacteristic : CBCharacteristic?
    
    /// Retrieves the maximum write value length supported by the associated device.
    public var maximumWriteValueLength : Int {
        get {
            return self.device.peripheral?.maximumWriteValueLength(for: CBCharacteristicWriteType.withResponse) ?? 20
        }
    }

    /// Creates a bluetooth service associated with the given device.
    ///
    /// - Parameter device: Parent bluetooth device.
    public override init(withDevice device: BleDevice) {
        self.transmitDataCharacteristic = nil
        self.receiveDataCharacteristic = nil
        super.init(withDevice: device)
    }
    
    /// Called when new data received.
    ///
    /// - Parameter incomingData: Data object with received data.
    @available(iOS 10.0, *)
    public func dataReceived(_ incomingData: Data) {
        if let delegate = self.delegate {
            delegate.dataReceived(incomingData)
        }
        else
        {
            let dataString = incomingData.hexDescription("-")
            os_log_ble("AmberBleService.dataReceived: no delegate, skipped data %s", type: .info, dataString)
        }
    }
    
    /// Tries to send the specified data to the device,
    ///
    /// - Parameter data: Data object to be send.
    @available(iOS 10.0, *)
    public func transmit(_ data: Data) {
        guard let transmitDataCharacteristic = self.transmitDataCharacteristic else {
            os_log_ble("AmberBleService.transmit: transmit pipe not ready", type: .error)
            return
        }
        
        var frameData = Data(bytes:[AmberBleService.kHeaderTypeUserData], count: 1)
        frameData.append(data)
        
        //os_log_ble("AmberBleService.transmit: data %s", type: .debug, frameData.hexDescription())
        
        self.device.peripheral?.writeValue(frameData, for: transmitDataCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    
    // MARK: BleServiceDelegate
    
    /// Called by the bluetooth device manager when the device connects.
    public func deviceDidConnect() {
        self.device.peripheral?.discoverServices(AmberBleService.serviceUUIDs())
    }
    
    /// Called by the bluetooth device manager when the device disconnects.
    public func deviceDidDisconnect() {
        self.transmitDataCharacteristic = nil
        self.receiveDataCharacteristic = nil
    }
    
    /// Called by the bluetooth device manager to determinate if the service wants to subscribe to the given characteristics
    ///
    /// - Parameter characteristic: Reference characteristics instance.
    /// - Returns: True if the service wants to subscribe to the characteristics.
    public func shouldSubscribe(toCharacteristic characteristic: CBCharacteristic) -> Bool {
        if (characteristic.uuid == AmberBleService.uartServiceReceiveCharacteristicUUID) {
            return true
        }
        
        return false
    }
    
    /// Called by the bluetooth device manager when a characterisitcs was discovered.
    ///
    /// - Parameter characteristic: Reference characteristics instance
    public func didDiscover(_ characteristic: CBCharacteristic) {
        if (characteristic.uuid == AmberBleService.uartServiceTransmitCharacteristicUUID) {
            self.transmitDataCharacteristic = characteristic
        }
        else
        if (characteristic.uuid == AmberBleService.uartServiceReceiveCharacteristicUUID) {
            self.receiveDataCharacteristic = characteristic
        }
    }
    
    /// Called by the bluetooth device manager when new data has been received for the given characterisitcs.
    ///
    /// - Parameters:
    ///   - characteristic: Reference characteristics instance.
    ///   - error: Error instance. Nil if no error has been provided.
    @available(iOS 10.0, *)
    public func didUpdate(valueForCharacteristic characteristic: CBCharacteristic, _ error: Error?) {
        guard characteristic == self.receiveDataCharacteristic else {
            os_log_ble("AmberBleService.didUpdate: unexpected characteristic instance reference", type: .error)
            return
        }
        
        guard var incomingData = characteristic.value else {
            os_log_ble("AmberBleService.didUpdate: data is nil", type: .error)
            return
        }
        
        guard incomingData.count > 0 else {
            os_log_ble("AmberBleService.didUpdate: missing header", type: .debug)
            return
        }
        
        let headerType = incomingData[0]
        
        guard headerType == AmberBleService.kHeaderTypeUserData else {
            os_log_ble("AmberBleService.didUpdate: data skipped, unknown header type 0x%02x", type: .debug, headerType)
            return
        }
        
        incomingData.removeFirst()
        self.dataReceived(incomingData)
    }
}
