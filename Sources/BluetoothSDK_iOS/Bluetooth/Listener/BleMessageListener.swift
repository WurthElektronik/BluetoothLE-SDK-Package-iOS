// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// BleListener protocol for events concerning messages.
public protocol BleMessageListener: BleListener {

    /// Should be called when a BluetoothMessage is transmitted to a bluetooth device.
    ///
    /// - Parameters: message: BluetoothMessage that was transmitted.
    func didTransmitMessage(message: BluetoothMessage)

    /// Should be called when a BluetoothMessage is received from a bluetooth device.
    ///
    /// - Parameters: message: BluetoothMessage that was received.
    func didReceiveMessage(message: BluetoothMessage)
}
