// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// Outgoing Message send by user containing payload.
public class OutgoingBluetoothMessage: BluetoothMessage {
    public var timestamp: Date
    public var message: Data
    public var transmitted: Bool = false

    public init(timestamp: Date, message: Data) {
        self.timestamp = timestamp
        self.message = message
    }

}
