//
//  MultiColorDriverBleDevice.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 09.07.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log


/// Bluetooth device class to handle the interaction with the wuerth multi color LED driver board.
@available(iOS 10.0, *)
open class MultiColorDriverBleDevice: AmberBleDevice, AmberBleServiceDelegate {
    
    // MARK: Shared static
    
    public override class func make(withPeripheral peripheral: CBPeripheral) -> MultiColorDriverBleDevice {
        return MultiColorDriverBleDevice(withPeripheral: peripheral)
    }
    
    /// String identifier definition for channel 1 property change
    public static let kPropertyChannel1 = "channel1"
    
    /// String identifier definition for channel 2 property change
    public static let kPropertyChannel2 = "channel2"
    
    /// String identifier definition for channel 3 property change
    public static let kPropertyChannel3 = "channel3"
    
    /// String identifier definition for channel 4 property change
    public static let kPropertyChannel4 = "channel4"
    
    /// String identifier definition for brightness channel property change
    public static let kPropertyChannelBrightness = "brightness"
    
    /// String identifier definition for connection state property change
    public static let kPropertyIsConnected = "isConnected"
    
    
    // MARK: Class implementation
    
    /// Holds internal change state of channel 1 property. Used to indacte that the property should be commited to the device.
    public private(set) var isChannel1Dirty = false
    public var channel1 : Float {
        didSet {
            self.delegate?.didSet(self, MultiColorDriverBleDevice.kPropertyChannel1, oldValue, self.channel1)
            if !self.blockActionTrigger {
                self.isChannel1Dirty = true
            }
            self.triggerSendActionTimer()
        }
    }
    
    /// Holds internal change state of channel 2 property. Used to indacte that the property should be commited to the device.
    public private(set) var isChannel2Dirty = false
    public var channel2 : Float {
        didSet {
            self.delegate?.didSet(self, MultiColorDriverBleDevice.kPropertyChannel2, oldValue, self.channel2)
            if !self.blockActionTrigger {
                self.isChannel2Dirty = true
            }
            self.triggerSendActionTimer()
        }
    }
    
    /// Holds internal change state of channel 3 property. Used to indacte that the property should be commited to the device.
    public private(set) var isChannel3Dirty = false
    public var channel3 : Float {
        didSet {
            self.delegate?.didSet(self, MultiColorDriverBleDevice.kPropertyChannel3, oldValue, self.channel3)
            if !self.blockActionTrigger {
                self.isChannel3Dirty = true
            }
            self.triggerSendActionTimer()
        }
    }
    
    /// Holds internal change state of channel 4 property. Used to indacte that the property should be commited to the device.
    public private(set) var isChannel4Dirty = false
    public var channel4 : Float {
        didSet {
            self.delegate?.didSet(self, MultiColorDriverBleDevice.kPropertyChannel4, oldValue, self.channel4)
            if !self.blockActionTrigger {
                self.isChannel4Dirty = true
            }
            self.triggerSendActionTimer()
        }
    }
    
    /// Holds internal change state of brightness channel property. Used to indacte that the property should be commited to the device.
    public private(set) var isChannelBrightnessDirty = false
    public var brightness : Float {
        didSet {
            self.delegate?.didSet(self, MultiColorDriverBleDevice.kPropertyChannelBrightness, oldValue, self.brightness)
            if !self.blockActionTrigger {
                self.isChannelBrightnessDirty = true
            }
            self.triggerSendActionTimer()
        }
    }
    
    /// Determinates if any device property has been changed. Used to indacte that properties should be commited to the device.
    public var isAnyChannelDirty : Bool {
        get {
            return [self.isChannel1Dirty, self.isChannel2Dirty, self.isChannel3Dirty, self.isChannel4Dirty, self.isChannelBrightnessDirty].contains(true)
        }
    }
    
    /// Property chanage delegate.
    public weak var delegate : PropertyChangedDelegate? = nil
    
    /// Default property chanage interval.
    public var sendActionDelayTimeout: TimeInterval = 0.1
    
    /// Property chnage commit timer.
    private var sendActionDelayTimeoutTimer : Timer? = nil
    
    /// Determinates if property change is blocked. Internal use to prevent ffedback loop.
    private var blockActionTrigger = true
    
    /// Default constructor. Does not interact with a physical device.
    public override init() {
        self.channel1 = 0.0
        self.channel2 = 0.0
        self.channel3 = 0.0
        self.channel4 = 0.0
        self.brightness = 0.0
        super.init()
        self.blockActionTrigger = false
    }
    
    /// Creates an instance wich is associateded with a peripheral interface.
    ///
    /// Used to interact with a physical device.
    ///
    /// - Parameter peripheral: Associated peripherale instance.
    required public init(withPeripheral peripheral: CBPeripheral) {
        self.channel1 = 0.0
        self.channel2 = 0.0
        self.channel3 = 0.0
        self.channel4 = 0.0
        self.brightness = 0.0
        super.init(withPeripheral: peripheral)
        self.serialService?.delegate = self
        self.blockActionTrigger = false
    }
    
    /// Retriggers and schedules transmit data timeout.
    ///
    /// - Parameter forced: Should be true if a sencd action should be froced.
    private func triggerSendActionTimer(force forced: Bool = false) {
        if !forced {
            if self.blockActionTrigger {
                return
            }
            
            guard self.sendActionDelayTimeoutTimer == nil else {
                return
            }
        }
        
        self.sendActionDelayTimeoutTimer?.invalidate()
        self.sendActionDelayTimeoutTimer = Timer.scheduledTimer(timeInterval: self.sendActionDelayTimeout, target: self,
                                                           selector: #selector(didSendActionTimeout), userInfo: nil, repeats: false)
    }
    
    /// Callback wich sends new object state to the device.
    @objc private func didSendActionTimeout() {
        self.isChannel1Dirty = false
        self.isChannel2Dirty = false
        self.isChannel3Dirty = false
        self.isChannel4Dirty = false
        self.isChannelBrightnessDirty = false
        
        self.sendActionDelayTimeoutTimer?.invalidate()
        self.sendActionDelayTimeoutTimer = nil
        
        let values = [self.brightness,  self.channel1, self.channel2, self.channel3, self.channel4]
        var data = Data(capacity: Int(MultiColorDriverMessage.kLength) * values.count)
        _ = MultiColorDriverMessage.dump(withChannelValues: values, to: &data)
        
        os_log_ble("MultiColorDriverBleDevice.dataSend:     %s", type: .info, data.hexDescription("-"))

        self.serialService?.transmit(data)
    }
    
    /// Notifies delegate about connection state change.
    public func triggerConnectionChanged() {
        if let delegate = self.delegate {
            let isConnected = self.isConnected
            delegate.didSet(self, MultiColorDriverBleDevice.kPropertyIsConnected, !isConnected, isConnected)
        }
    }
    
    
    // MARK: AmberBleServiceDelegate
    
    /// Handles incoming multicolor LED driver bluetotoh data.
    ///
    /// - Parameter incomingData: Incoming data instance.
    public func dataReceived(_ incomingData: Data) {
        
        // we do not want to trigger any commits during receptions
        self.blockActionTrigger = true
        defer {
            self.blockActionTrigger = false
        }
        
        os_log_ble("MultiColorDriverBleDevice.dataReceived: %s", type: .info, incomingData.hexDescription("-"))
        
        // force delay send timer if any dirty value is pending
        if self.isAnyChannelDirty {
            self.triggerSendActionTimer(force: true)
        }
        
        // process messages
        for message in MultiColorDriverMessage.make(with: incomingData) {
            let value = message.floatValue
            
            switch message.channel {
            case 0:
                if !self.isChannelBrightnessDirty {
                    self.brightness = value
                }
                break;
            case 1:
                if !self.isChannel1Dirty {
                    self.channel1 = value
                }
                break;
            case 2:
                if !self.isChannel2Dirty {
                    self.channel2 = value
                }
                break;
            case 3:
                if !self.isChannel3Dirty {
                    self.channel3 = value
                }
                break;
            case 4:
                if !self.isChannel4Dirty {
                    self.channel4 = value
                }
                break;
            default:
                break;
            }
        }
    }
    
    
    // MARK: BleDeviceDelegate
    
    public override func didConnect() {
        super.didConnect()
        self.triggerConnectionChanged()
    }
    
    public override func didDisconnect() {
        super.didDisconnect()
        self.triggerConnectionChanged()
    }
}
