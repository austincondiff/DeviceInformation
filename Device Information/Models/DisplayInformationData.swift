//
//  DisplayInformationData.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct DisplayInformationData {
    #if os(macOS)
    let screen: NSScreen
    
    init(screen: NSScreen) {
        self.screen = screen
    }
    
    var type: String {
        screen.localizedName.lowercased().contains("built-in") ? "Built-in" : "External"
    }
    
    var resolution: String {
        "\(Int(screen.frame.width)) x \(Int(screen.frame.height))"
    }
    
    var scaleFactor: String {
        String(format: "%.1fx", screen.backingScaleFactor)
    }

    var refreshRate: Int? {
        guard let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return nil
        }
        let mode = CGDisplayCopyDisplayMode(displayID)
        return Int(mode?.refreshRate ?? 0)
    }
    
    var pixelDensity: Int? {
        DisplayInformationData.getScreenPPI()
    }
    
    #else
    // Add empty initializer for iOS
    init() {
        // No initialization needed for iOS
    }
    
    var scaleFactor: String {
        String(format: "%.1fx", UIScreen.main.scale)
    }
    
    var refreshRate: Int? {
        UIScreen.main.maximumFramesPerSecond
    }
    
    var resolution: String {
        let screen = UIScreen.main
        return "\(Int(screen.bounds.width * screen.scale)) x \(Int(screen.bounds.height * screen.scale))"
    }
    
    var pixelDensity: Int? {
        DisplayInformationData.getScreenPPI()
    }
    #endif
    
    /// Approximate PPI (Pixels Per Inch) for common iPhone and Mac models
    static func getScreenPPI() -> Int? {
        let identifier = getDeviceIdentifier()

        let ppiMap: [String: Int] = [
            // iPhone Models
            "iPhone16,1": 460, // iPhone 15 Pro
            "iPhone16,2": 460, // iPhone 15 Pro Max
            "iPhone15,4": 460, // iPhone 15
            "iPhone15,5": 460, // iPhone 15 Plus
            "iPhone15,3": 460, // iPhone 14 Pro Max
            "iPhone15,2": 460, // iPhone 14 Pro
            "iPhone14,7": 460, // iPhone 14
            "iPhone14,5": 460, // iPhone 13
            "iPhone13,2": 460, // iPhone 12
            "iPhone12,1": 326, // iPhone 11
            "iPhone11,8": 326, // iPhone XR
            "iPhone10,6": 458, // iPhone X

            // Mac Models
            "MacBookPro18,3": 254, // MacBook Pro 14" M1 Pro
            "MacBookPro18,4": 254, // MacBook Pro 16" M1 Max
            "MacBookPro19,1": 254, // MacBook Pro 14" M2 Pro
            "MacBookPro19,2": 254, // MacBook Pro 16" M2 Max
            "iMac21,1": 218, // iMac 24-inch M1
            "iMac21,2": 218, // iMac 24-inch M1
        ]

        return ppiMap[identifier]
    }
    
    /// Get the device identifier (e.g., "iPhone15,3" for iPhone 14 Pro Max, "MacBookPro18,3" for Mac)
    static func getDeviceIdentifier() -> String {
        var size = 0
        let identifierKey = "hw.machine"

        sysctlbyname(identifierKey, nil, &size, nil, 0)
        guard size > 0 else { return "Unknown Device" }

        var model = [CChar](repeating: 0, count: size)
        sysctlbyname(identifierKey, &model, &size, nil, 0)

        return String(cString: model)
    }
}
