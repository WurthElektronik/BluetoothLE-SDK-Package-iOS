// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

/// The Received Signal Strength Indicator type.
public enum RSSI: Int {
    /// Almost unusable signal strength below -85 dBm.
    case unusable = -96
    /// Low signal strength between -85 dBm and -76 dBm.
    case low = -76
    /// Medium signal strength below between -75 dB and -56 dBm.
    case medium = -56
    /// High signal strength above -56 dBm.
    case high = -55

    public init(_ value: Int) {
        self = RSSI.getRSSI(value)
    }

    public static func getRSSI(_ value: Int) -> RSSI {
        if value >= RSSI.high.rawValue {
            return .high
        } else if value < RSSI.high.rawValue && value > RSSI.low.rawValue  {
            return .medium
        } else if value < RSSI.medium.rawValue && value > RSSI.unusable.rawValue {
            return .low
        }
        return .unusable
    }
}
