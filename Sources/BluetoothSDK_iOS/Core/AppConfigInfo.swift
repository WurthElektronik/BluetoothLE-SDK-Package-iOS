//
//  AppConfigInfo.swift
//  HortiCoolture
//
//  Created by Vitalij Mast on 19.07.19.
//  Copyright © 2019 Synergetik GmbH. All rights reserved.
//

#if !APP_ENABLE_PRIVACY_ON_FIRST_STARTUP
    #warning("APP_ENABLE_PRIVACY_ON_FIRST_STARTUP is unset. If you want to show the privacy policy on the first start define this Flag under 'Build Settings' > 'Swift Compiler - Custom Flags'.")
#endif

#if !APP_ENABLE_DEVICE_RENAME
    #warning("APP_ENABLE_DEVICE_RENAME is unset. If you want to enable device renaming define this Flag under 'Build Settings' > 'Swift Compiler - Custom Flags'.")
#endif

#if !APP_ENABLE_SETTINGS
    #warning("APP_ENABLE_SETTINGS is unset. If you want to enable the storage fo user settings define this Flag under 'Build Settings' > 'Swift Compiler - Custom Flags'.")
#endif


#if (!APP_ENABLE_SETTINGS) && (APP_ENABLE_PRIVACY_ON_FIRST_STARTUP || APP_ENABLE_DEVICE_RENAME)
    #error("Wrong configuration: APP_ENABLE_SETTINGS must be set if either APP_ENABLE_PRIVACY_ON_FIRST_STARTUP or/and APP_ENABLE_DEVICE_RENAME is set.")
#endif
