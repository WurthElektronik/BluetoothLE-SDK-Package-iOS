// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import _SwiftOSOverlayShims
import Foundation
import os.log

@available(iOS 10.0, *)
extension OSLog {
    
    /// Default logging subsystem identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    
    /// Logging instance for application 'core' module.
    public static let categoryCore = OSLog(subsystem: subsystem, category: "core")
    
    /// Logging instance for application 'ble' module.
    public static let categoryBle = OSLog(subsystem: subsystem, category: "ble")
    
    /// Logging instance for application 'ui' module.
    public static let categoryUi = OSLog(subsystem: subsystem, category: "ui")
}


/// Formats and sends a message at a specific logging level, such as default, info, debug, error, or fault, to the logging system.
///
/// Calling this function doesn’t ensure that a message is logged.
/// Logging always occurs in accordance with the behavior settings of the provided log object and type.
/// Note that lengthy log messages may be truncated when stored by the logging system.
///
/// Default-level messages sent by this function are initially stored in memory.
/// Without a configuration change, they are moved to the data store as memory buffers fill.
/// They remain there until the storage quota is exceeded, at which point, the oldest messages are purged.
///
/// - Parameters:
///   - message: A constant string or format string that produces a human-readable log message. See Formatting Log Messages.
///   - log: A custom log object. If unspecified, the shared default log is used.
///   - type: The log level. If unspecified, the default log level is used. Accepted values are default, info, debug, error or fault.
///   - valist: Variable argument list used with the format message. If message is a constant string, do not specify arguments.
///             If message is a format string, pass the expected number of arguments in the order that they appear in the string.
@available(iOS 10.0, *)
private func os_logv(_ message: StaticString, dso: UnsafeRawPointer? = #dsohandle, log: OSLog = .default, type: OSLogType = .default, _ valist: CVaListPointer) {
    guard log.isEnabled(type: type) else {
        return
    }
    let ra = _swift_os_log_return_address()
    
    message.withUTF8Buffer { (buf: UnsafeBufferPointer<UInt8>) in
        buf.baseAddress!.withMemoryRebound(to: CChar.self, capacity: buf.count) { str in
            _swift_os_log(dso, ra, log, type, str, valist)
        }
    }
}

/// Formats and sends an message to the 'ble' logging system.
///
/// - Parameters:
///   - message: A constant string or format string that produces a human-readable log message. See Formatting Log Messages.
///   - type: The log level. If unspecified, the default log level is used. Accepted values are default, info, debug, error or fault.
///   - args: If message is a constant string, do not specify arguments.
///           If message is a format string, pass the expected number of arguments in the order that they appear in the string.
@available(iOS 10.0, *)
public func os_log_ble(_ message: StaticString, type: OSLogType = .default, _ args: CVarArg...) {
    os_logv(message, log: OSLog.categoryBle, type: type, getVaList(args))
}

/// Formats and sends an message to the 'ui' logging system.
///
/// - Parameters:
///   - message: A constant string or format string that produces a human-readable log message. See Formatting Log Messages.
///   - type: The log level. If unspecified, the default log level is used. Accepted values are default, info, debug, error or fault.
///   - args: If message is a constant string, do not specify arguments.
///           If message is a format string, pass the expected number of arguments in the order that they appear in the string.
@available(iOS 10.0, *)
public func os_log_ui(_ message: StaticString, type: OSLogType = .default, _ args: CVarArg...) {
    os_logv(message, log: OSLog.categoryUi, type: type, getVaList(args))
}

/// Formats and sends an message to the 'core' logging system.
///
/// - Parameters:
///   - message: A constant string or format string that produces a human-readable log message. See Formatting Log Messages.
///   - type: The log level. If unspecified, the default log level is used. Accepted values are default, info, debug, error or fault.
///   - args: If message is a constant string, do not specify arguments.
///           If message is a format string, pass the expected number of arguments in the order that they appear in the string.
@available(iOS 10.0, *)
public func os_log_core(_ message: StaticString, type: OSLogType = .default, _ args: CVarArg...) {
    os_logv(message, log: OSLog.categoryCore, type: type, getVaList(args))
}
