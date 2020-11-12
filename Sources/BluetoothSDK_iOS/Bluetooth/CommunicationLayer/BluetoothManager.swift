// __          ________        _  _____
// \ \        / /  ____|      (_)/ ____|
//  \ \  /\  / /| |__      ___ _| (___   ___  ___
//   \ \/  \/ / |  __|    / _ \ |\___ \ / _ \/ __|
//    \  /\  /  | |____  |  __/ |____) | (_) \__ \
//     \/  \/   |______|  \___|_|_____/ \___/|___/
//
// Copyright © 2020 Würth Elektronik GmbH & Co. KG.

import Foundation

// MARK: Class implementation

/// BluetoothManager is an easy to use bluetooth layer for communicating with the corresponding devices.
@available(iOS 10.0, *)
public class BluetoothManager: NSObject, BluetoothManagerProtocol {

    /// Shared instance of the BluetoothManager.
    public static let shared: BluetoothManagerProtocol = BluetoothManager()

    /// Listens to different bluetooth events.
    public weak var listener: BleListener?

    /// Collects all Bluetooth Messages.
    public var messages: [BluetoothMessage] = []

    /// Timer for received signal strength indicator (RSSI) refresh updates to connected Device.
    private var rssiRefreshTimer: Timer?

    /// Refresh interval for rssiRefreshTimer in seconds.
    private let refreshRSSIInterval: Double = 1

    /// The maximum length of one payload package.
    ///
    /// - Remark: Will be determined when MTU of connected device is retrieved.
    public var maximumPayloadByteLength: Int? = nil

    /// Starts rssiRefreshTimer.
    private func startReadingRSSI() {
        stopReadingRSSI()
        rssiRefreshTimer = Timer.scheduledTimer(timeInterval: refreshRSSIInterval, target: self, selector: #selector(readRSSI), userInfo: nil, repeats: true)
    }

    /// Stops rssiRefreshTimer.
    private func stopReadingRSSI() {
        rssiRefreshTimer?.invalidate()
        rssiRefreshTimer = nil
    }

    /// Received signal strength indicator (RSSI) refresh timer event.
    @objc func readRSSI() {
        connectedDevice?.refreshRSSI()
    }

    override init() {
        super.init()
        deviceManager.delegate = self
    }

    /// Current connected Bluetooth Device. Nil if no device is connected.
    public var connectedDevice: BleDevice? {
        get {
            return deviceManager.connectedDevices.first
        }
    }

    /// Contains all active scanned Bluetooth devices matching the corresponding configuration.
    public var devices: [BleDevice] {
        get {
            return deviceManager.devices
        }
    }

    /// Handels connection with bluetooth devices.
    private var deviceManager : BleDeviceManager = AmberBleDeviceManager.shared

    /// Applies new UartConfig to the bluetooth service. Bluetooth communication will only listen for the newest applied configuration.
    ///
    /// - Parameter config: UartConfig.Type. Default AmberUartConfig.
    public func applyConfiguration(config: UartConfig.Type = AmberUartConfig.self) {
        AmberBleService.uartConfig = config
    }

    /// Transmits data to current connected bluetooth device. Data will not be transferred if connection is interrupted.
    /// An outgoing message will be added to message array.
    /// - Parameter data: Data that will be transmitted.
    public func sendData(data: Data) {
        guard let device = deviceManager.connectedDevices.first as? AmberBleDevice else {
            os_log_ble("BluetoothManager.sendData: no device connected", type: .error)
            return
        }
        device.serialService?.transmit(data)
        let message = OutgoingBluetoothMessage(timestamp: Date(), message: data)
        appendMessage(message: message)
    }

    /// Connects to the device and sets the delegate to the serial service of the device.
    ///
    /// - Parameter device: Bluetooth Device that will be connected.
    public func connect(toDevice device: BleDevice) {
        guard let amberDevice = device as? AmberBleDevice else {
            os_log_ble("BluetoothManager.connect: incompatible BleDevice type", type: .error)
            return
        }
        deviceManager.connect(toDevice: amberDevice)
        amberDevice.serialService?.delegate = self
    }

    //// Disconnects from the current connected Bluetooth device. No action if no device is connected.
    public func disconnect() {
        guard let device = deviceManager.connectedDevices.first else {
            os_log_ble("BluetoothManager.disconnect: no device connected", type: .info)
            return
        }
        deviceManager.disconnect(fromDevice: device)
    }

    /// Activates the scanning for bluetooth devices matching the corresponding configuration.
    public func activateScanning() {
        deviceManager.isScanning = true
    }

    /// Deactivates the scanning for bluetooth devices. No new devices will be found.
    public func deactivateScanning() {
        deviceManager.isScanning = false
    }

    /// Appends a new BluetoothMessage to the messages array. BleMessageListener will listen for this event.
    ///
    /// - Parameter message: BluetoothMessage that will be added.
    private func appendMessage(message: BluetoothMessage) {
        var messages = [BluetoothMessage]()
        messages.append(contentsOf: self.messages)
        messages.append(message)
        self.messages = messages

        guard let listener = listener as? BleMessageListener else {
            os_log_ble("BluetoothManager.appendMessage: listener is no BleMessageListener", type: .info)
            return
        }

        if let outgoingMessage = message as? OutgoingBluetoothMessage {
            listener.didTransmitMessage(message: outgoingMessage)
        } else {
            listener.didReceiveMessage(message: message)
        }
    }

}

// MARK: AmberBleServiceDelegate

@available(iOS 10.0, *)
extension BluetoothManager: AmberBleServiceDelegate {

    /// Will be called when serial service of connected device gets a new payload message.
    /// An incoming message will be added to message array.
    ///
    /// - Parameter incomingData: received data from connected bluetooth device.
    public func dataReceived(_ incomingData: Data) {
        let message = IncomingBluetoothMessage(timestamp: Date(), message: incomingData)
        appendMessage(message: message)
    }

    /// Will be called when serial service of connected device reads received signal strength indicator (RSSI).
    public func didReadRSSI() {
        guard let device = connectedDevice else {
            return
        }
        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didConnectToDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didUpdateDevice(device: device)
    }

}

// MARK: BluetoothManagerDelegate

@available(iOS 10.0, *)
extension BluetoothManager: BleDeviceManagerDelegate {

    /// Will be called when device manager discovers a bluetooth device.
    /// An info message will be added to message array about device discovery.
    public func deviceManager(_ manager: BleDeviceManager, didDiscoverDevice device: BleDevice){
        appendMessage(message: InfoBluetoothMessage(timestamp: Date(), message: "Discovered \(device.name) - \(device.uuidShortString)"))
        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didDiscoverDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didDiscoverDevice(device: device)
    }

    /// Will be called when device manager connects successfully to a bluetooth device.
    ///
    /// An info message will be added to message array about device connection.
    /// An info message will be added to message array about discoverd mtu.
    public func deviceManager(_ manager: BleDeviceManager, didConnectToDevice device: BleDevice){
        appendMessage(message: InfoBluetoothMessage(timestamp: Date(), message: "Connected to \(device.uuidShortString)"))
        if let mtu = device.mtu {
            maximumPayloadByteLength = mtu
            appendMessage(message: InfoBluetoothMessage(timestamp: Date(), message: "Discovered mtu: \(mtu)"))
        }
        startReadingRSSI()

        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didConnectToDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didConnectToDevice(device: device)
    }

    /// Will be called when device manager disconnects from a bluetooth device.
    /// An info message will be added to message array about device disconnection.
    public func deviceManager(_ manager: BleDeviceManager, didDisconnectFromDevice device: BleDevice){
        appendMessage(message: InfoBluetoothMessage(timestamp: Date(), message: "Disconnected from \(device.uuidShortString)"))
        maximumPayloadByteLength = nil
        stopReadingRSSI()
        
        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didDisconnectFromDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didDisconnectFromDevice(device: device)
    }

    /// Will be called when device manager could not establish connection to a bluetooth device.
    /// An info message will be added to message array about failed connection.
    public func deviceManager(_ manager: BleDeviceManager, didFailToConnectToDevice device: BleDevice) {
        appendMessage(message: InfoBluetoothMessage(timestamp: Date(), message: "Failed to connect to \(device.uuidShortString)"))
        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didDidFailToConnectToDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didFailToConnectToDevice(device: device)
    }

    /// Will be called when device manager discovered an update for a device.
    public func deviceManager(_ manager: BleDeviceManager, didUpdateDevice device: BleDevice) {
        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didUpdateDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didUpdateDevice(device: device)
    }

    /// Will be called when device manager removes a discovered device.
    public func deviceManager(_ manager: BleDeviceManager, didLoseDevice device: BleDevice) {
        guard let listener = listener as? BleConnectionListener else {
            os_log_ble("BluetoothManager.deviceManager didLoseDevice: listener is no BleConnectionListener", type: .info)
            return
        }
        listener.didLoseDevice(device: device)
    }
}
