// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// BluetoothManager  protocol. An easy to use bluetooth layer for communicating with the corresponding devices.
@available(iOS 10.0, *)
public protocol BluetoothManagerProtocol: class {

    /// Listens to different bluetooth events.
    var listener: BleListener? { get set }

    /// Collects all Bluetooth Messages.
    var messages: [BluetoothMessage] { get set }

    /// Current connected Bluetooth Device. Nil if no device is connected.
    var connectedDevice: BleDevice? { get }

    /// Contains all active scanned Bluetooth devices matching the corresponding configuration.
    var devices: [BleDevice] { get }

    /// The maximum length of one payload package.
    ///
    /// - Remark: Will be determined when MTU of connected device is retrieved.
    var maximumPayloadByteLength: Int? { get set }

    /// Applies new UartConfig to the bluetooth service.
    ///
    /// - Parameter config: UartConfig.Type.
    func applyConfiguration(config: UartConfig.Type)

    /// Transmits data to current connected Bluetooth Device. Data will not be transferred if connection is interrupted.
    ///
    /// - Parameter data: Data that will be transmitted.
    func sendData(data: Data)

    /// Connects to the device.
    ///
    /// - Parameter device: Bluetooth Device that will be connected.
    func connect(toDevice device: BleDevice)

    /// Disconnects from the current connected Bluetooth device. No action if no device is connected.
    func disconnect()

    /// Activates the scanning for bluetooth devices matching the corresponding configuration.
    func activateScanning()

    /// Deactivates the scanning for bluetooth devices. No new devices will be found.
    func deactivateScanning()
}
