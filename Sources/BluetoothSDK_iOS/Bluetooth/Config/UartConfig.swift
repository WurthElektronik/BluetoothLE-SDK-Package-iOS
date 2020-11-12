// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// UartConfig is used to define the uart configuration of your corresponding bluetooth device.
public protocol UartConfig {

    /// Payload header type definition for user data.
    static var kHeaderTypeUserData: Int { get }

    /// Associated service UUID as string.
    static var kUartServiceUUID: String { get }

    /// Associated characteristics transmit UUID as string.
    static var kUartServiceTransmitCharacteristicUUID: String { get }

    /// Associated characteristics receive UUID as string.
    static var kUartServiceReceiveCharacteristicUUID: String { get }

    /// Minimum Received signal strength indicator (RSSI) value for discovery of bluetooth devices.
    ///
    /// Devices below minimum will not be discovered. No restrictions if minimum is nil.
    static var minimumRSSI: Int? { get }

    /// Maximum count for bad Received signal strength indicator (RSSI) measurement.
    ///
    /// If maximum is reached for a discovered bluetooth device, this device will be removed from discovery. Device will not be removed if value nil.
    static var maximumBadRSSICount: Int? { get }
}
