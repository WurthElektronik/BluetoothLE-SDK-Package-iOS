// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// BleListener protocol for events concerning connection.
@available(iOS 10.0, *)
public protocol BleConnectionListener: BleListener {

    /// Should be called when a bluetooth connection was established with a bluetooth device.
    ///
    /// - Parameters: device: BleDevice that was connected.
    func didConnectToDevice(device: BleDevice)

    /// Should be called when a bluetooth connection could not be established with a bluetooth device.
    ///
    /// - Parameters: device: BleDevice that was not able to be connected.
    func didFailToConnectToDevice(device: BleDevice)

    /// Should be called when a bluetooth connection was closed or lost with a bluetooth device.
    ///
    /// - Parameters: device: BleDevice that has disconnected.
    func didDisconnectFromDevice(device: BleDevice)

    /// Should be called when a bluetooth device was discovered.
    ///
    /// - Parameters: device: BleDevice that has been discovered.
    func didDiscoverDevice(device: BleDevice)

    /// Should be called when a bluetooth device was updated.
    ///
    /// - Parameters: device: BleDevice that has been updated.
    func didUpdateDevice(device: BleDevice)

    /// Should be called when a bluetooth device was lost from discovery.
    ///
    /// - Parameters: device: BleDevice that has been lost.
    func didLoseDevice(device: BleDevice)
}
