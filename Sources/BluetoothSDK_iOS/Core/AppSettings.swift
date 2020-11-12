//
//  AppSettings.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 14.06.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

import Foundation
import os.log


/// Static AppSettings class is used to store and retrive app specific configurations.
class AppSettings {
    
    // MARK: Properties

    /// Key value for device custom name list.
    public static let deviceCustomNameListKey: String = "deviceCustomNameList";
    
    /// List of custom device names
    private static var deviceCustomNameList : Dictionary<String, String>? = nil
    
    /// Retrives stored custom name for specified device identifier.
    ///
    /// - Parameter deviceId: Device identifier.
    /// - Returns: Custom name for the specified device if any, else nil.
    public static func getDeviceCustomName(_ deviceId: String) -> String? {
        return deviceCustomNameList![deviceId]
    }
    
    /// Sets or overrides custom device name for specified device identifier.
    ///
    /// - Parameters:
    ///   - deviceId: Device identifier.
    ///   - name: New custom device name.
    public static func setDeviceCustomName(_ deviceId: String, _ name: String?) {
        if name?.isEmpty ?? true {
            deviceCustomNameList!.removeValue(forKey: deviceId)
        }
        else {
           deviceCustomNameList![deviceId] = name
        }
    }
    
    
    /// Key value for privacy policy accepted.
    public static let privacyPolicyAcceptedKey: String = "privacyPolicyAccepted";
    
    /// Retrives or stores the state of privacy policy acception.
    public static var isPrivacyPolicyAccepted: Bool {
        get {
            return data?.bool(forKey: privacyPolicyAcceptedKey) ?? false
        }
        set(accepted) {
            if (accepted != isPrivacyPolicyAccepted) {
                data?.set(accepted, forKey: privacyPolicyAcceptedKey)
                data?.synchronize()
            }
        }
    }
    
    // MARK: Generic
    
    /// Default storage instance.
    ///
    /// Only set if APP_ENABLE_SETTINGS is enabled, else nil.
    private static var data: UserDefaults? {
        get {
#if APP_ENABLE_SETTINGS
            return UserDefaults.standard
#else
            return nil
#endif
        }
    }
    
    /// This class can not be instantiated, because it contains only static methods.
    private init() {}
    
    /// Prepares the AppSettings for usage.
    public static func setup() {
        deviceCustomNameList = (data?.dictionary(forKey: deviceCustomNameListKey) as? Dictionary<String, String>?) ?? nil
        if deviceCustomNameList == nil {
            deviceCustomNameList = Dictionary<String, String>()
        }
    }
    
    /// Stores outstanding app specific configurations to the system.
    public static func sync() {
        data?.set(deviceCustomNameList, forKey: deviceCustomNameListKey)
        data?.synchronize()
    }
}
