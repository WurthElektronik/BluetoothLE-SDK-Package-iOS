// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// Incoming message from Bluetooth Device containing payload.
public class IncomingBluetoothMessage: BluetoothMessage {
    public var timestamp: Date
    public var message: Data

    public init(timestamp: Date, message: Data) {
        self.timestamp = timestamp
        self.message = message
    }

}
