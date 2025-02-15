//
//  SystemInformationData.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct SystemInformationData {
    let systemName: String
    let systemVersion: String
    let systemBuild: String
    
    init() {
        #if os(iOS)
        self.systemName = UIDevice.current.systemName
        self.systemVersion = UIDevice.current.systemVersion
        #else
        self.systemName = "macOS"
        self.systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        #endif
        
        self.systemBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}


