//
//  DeviceInformationData.swift
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

struct DeviceInformationData {
    let deviceName: String
    let deviceModel: String
    let physicalDevice: String
    let deviceType: String
    
    init() {
        #if os(iOS)
        self.deviceName = UIDevice.current.name
        self.deviceModel = UIDevice.current.model
        self.physicalDevice = UIDevice.current.localizedModel
        self.deviceType = UIDevice.current.userInterfaceIdiom.description
        #else
        self.deviceName = Host.current().localizedName ?? "Unknown"
        self.deviceModel = DeviceInfo.getSimpleDeviceName()
        self.physicalDevice = DeviceInfo.getDeviceIdentifier()
        self.deviceType = "Mac"
        #endif
    }
}


// MARK: - Device Info Helper Functions
struct DeviceInfo {
#if os(macOS)
    static func getBatteryPercentage() -> Int? {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFDictionary] else {
            return nil
        }

        for source in sources {
            if let info = source as? [String: Any],
               let capacity = info[kIOPSCurrentCapacityKey as String] as? Int {
                return capacity
            }
        }
        return nil
    }
#endif

    static func formattedUptime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let uptimeInterval = TimeInterval(uptime)

        let days = Int(uptimeInterval) / 86400
        let hours = (Int(uptimeInterval) % 86400) / 3600
        let minutes = (Int(uptimeInterval) % 3600) / 60
        let seconds = Int(uptimeInterval) % 60

        return "\(days > 0 ? "\(days)d " : "")\(hours)h \(minutes)m \(seconds)s"
    }

    static func getBootTime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let bootDate = Date(timeIntervalSinceNow: -uptime)

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"

        return formatter.string(from: bootDate)
    }

    static func getLocalIPAddresses() -> (ipv4: String?, ipv6: String?) {
        var ipv4Address: String?
        var ipv6Address: String?
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            
            while ptr != nil {
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        let result = getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                               &hostname, socklen_t(hostname.count),
                                               nil, 0, NI_NUMERICHOST)
                        if result == 0 {
                            let address = String(cString: hostname)
                            if addrFamily == UInt8(AF_INET) {
                                ipv4Address = address
                            } else if addrFamily == UInt8(AF_INET6) {
                                ipv6Address = address
                            }
                        }
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        return (ipv4Address, ipv6Address)
    }

    static func getSimpleDeviceName() -> String {
        let identifier = getDeviceIdentifier()

        if identifier.contains("MacBook") {
            return "MacBook Pro"
        } else if identifier.contains("iMac") {
            return "iMac"
        } else if identifier.contains("Macmini") {
            return "Mac mini"
        } else if identifier.contains("MacPro") {
            return "Mac Pro"
        } else if identifier.contains("iPhone") {
            return "iPhone"
        } else if identifier.contains("iPad") {
            return "iPad"
        } else {
            return "Unknown Device"
        }
    }

    static func getDeviceIdentifier() -> String {
        var size = 0
        #if os(macOS)
        let identifierKey = "hw.model"
        #else
        let identifierKey = "hw.machine"
        #endif

        sysctlbyname(identifierKey, nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname(identifierKey, &model, &size, nil, 0)

        return String(cString: model)
    }

#if os(macOS)
    static func getSerialNumber() -> String {
        let process = Process()
        process.launchPath = "/usr/sbin/system_profiler"
        process.arguments = ["SPHardwareDataType"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if let range = output.range(of: "Serial Number (system): ") {
            let serialLine = output[range.upperBound...].split(separator: "\n").first ?? ""
            return String(serialLine).trimmingCharacters(in: .whitespaces)
        }

        return "Unknown Serial Number"
    }
#endif

    static func getChipset() -> String {
        #if os(macOS)
        var size: Int = 0
        let chipsetKey = "machdep.cpu.brand_string"

        if sysctlbyname(chipsetKey, nil, &size, nil, 0) != 0 {
            return "Unknown Chipset"
        }

        guard size > 0 else { return "Unknown Chipset" }

        var brand = [CChar](repeating: 0, count: size)

        if sysctlbyname(chipsetKey, &brand, &size, nil, 0) != 0 {
            return "Unknown Chipset"
        }

        let chipString = String(cString: brand)

        if chipString.contains("Intel") {
            return "Intel"
        } else if chipString.contains("Apple") {
            return "Apple Silicon (\(chipString))"
        } else {
            return "Unknown Chipset"
        }

        #elseif os(iOS)
        let identifier = getDeviceIdentifier()
        let chipset = mapDeviceToChipset(identifier: identifier)

        print("Device Identifier: \(identifier), Chipset: \(chipset)") // Debugging log
        return chipset
        #endif
    }
    
    static func mapDeviceToChipset(identifier: String) -> String {
        let chipsetMap: [String: String] = [
            // iPhone Models
            "iPhone16,1": "Apple A17 Pro", // iPhone 15 Pro
            "iPhone16,2": "Apple A17 Pro", // iPhone 15 Pro Max
            "iPhone15,4": "Apple A16 Bionic", // iPhone 15
            "iPhone15,5": "Apple A16 Bionic", // iPhone 15 Plus
            "iPhone15,3": "Apple A16 Bionic", // iPhone 14 Pro / Pro Max
            "iPhone15,2": "Apple A16 Bionic", // iPhone 14 Pro
            "iPhone14,7": "Apple A15 Bionic", // iPhone 14
            "iPhone14,8": "Apple A15 Bionic", // iPhone 14 Plus
            "iPhone14,5": "Apple A15 Bionic", // iPhone 13
            "iPhone14,4": "Apple A15 Bionic", // iPhone 13 mini
            "iPhone13,2": "Apple A14 Bionic", // iPhone 12
            "iPhone13,1": "Apple A14 Bionic", // iPhone 12 mini
            "iPhone12,5": "Apple A13 Bionic", // iPhone 11 Pro Max
            "iPhone12,3": "Apple A13 Bionic", // iPhone 11 Pro
            "iPhone12,1": "Apple A13 Bionic", // iPhone 11
            "iPhone11,8": "Apple A12 Bionic", // iPhone XR
            "iPhone11,6": "Apple A12 Bionic", // iPhone XS Max
            "iPhone11,4": "Apple A12 Bionic", // iPhone XS
            "iPhone11,2": "Apple A12 Bionic", // iPhone XS
            "iPhone10,6": "Apple A11 Bionic", // iPhone X (GSM)
            "iPhone10,3": "Apple A11 Bionic", // iPhone X
            "iPhone10,5": "Apple A11 Bionic", // iPhone 8 Plus
            "iPhone10,4": "Apple A11 Bionic", // iPhone 8
            "iPhone9,2": "Apple A10 Fusion", // iPhone 7 Plus
            "iPhone9,1": "Apple A10 Fusion", // iPhone 7
            "iPhone9,4": "Apple A10 Fusion", // iPhone 7 Plus
            "iPhone9,3": "Apple A10 Fusion", // iPhone 7
            "iPhone8,2": "Apple A9", // iPhone 6s Plus
            "iPhone8,1": "Apple A9", // iPhone 6s
            "iPhone7,2": "Apple A8", // iPhone 6
            "iPhone7,1": "Apple A8", // iPhone 6 Plus
            "iPhone6,2": "Apple A7", // iPhone 5s
            "iPhone6,1": "Apple A7", // iPhone 5s

            // iPad Models
            "iPad14,1": "Apple M2", // iPad Pro 11-inch (4th Gen)
            "iPad14,2": "Apple M2", // iPad Pro 12.9-inch (6th Gen)
            "iPad13,16": "Apple M1", // iPad Air (5th Gen)
            "iPad13,17": "Apple M1", // iPad Air (5th Gen)
            "iPad13,4": "Apple M1", // iPad Pro 11-inch (3rd Gen)
            "iPad13,5": "Apple M1", // iPad Pro 11-inch (3rd Gen)
            "iPad13,6": "Apple M1", // iPad Pro 11-inch (3rd Gen)
            "iPad13,7": "Apple M1", // iPad Pro 11-inch (3rd Gen)
            "iPad13,8": "Apple M1", // iPad Pro 12.9-inch (5th Gen)
            "iPad13,9": "Apple M1", // iPad Pro 12.9-inch (5th Gen)
            "iPad13,10": "Apple M1", // iPad Pro 12.9-inch (5th Gen)
            "iPad13,11": "Apple M1", // iPad Pro 12.9-inch (5th Gen)
            "iPad8,1": "Apple A12X Bionic", // iPad Pro 11-inch (1st Gen)
            "iPad8,2": "Apple A12X Bionic", // iPad Pro 11-inch (1st Gen)
            "iPad8,3": "Apple A12X Bionic", // iPad Pro 11-inch (1st Gen)
            "iPad8,4": "Apple A12X Bionic", // iPad Pro 11-inch (1st Gen)
            "iPad8,5": "Apple A12X Bionic", // iPad Pro 12.9-inch (3rd Gen)
            "iPad8,6": "Apple A12X Bionic", // iPad Pro 12.9-inch (3rd Gen)
            "iPad8,7": "Apple A12X Bionic", // iPad Pro 12.9-inch (3rd Gen)
            "iPad8,8": "Apple A12X Bionic", // iPad Pro 12.9-inch (3rd Gen)
            "iPad11,1": "Apple A12 Bionic", // iPad mini (5th Gen)
            "iPad11,2": "Apple A12 Bionic", // iPad mini (5th Gen)
            "iPad11,3": "Apple A12 Bionic", // iPad Air (3rd Gen)
            "iPad11,4": "Apple A12 Bionic", // iPad Air (3rd Gen)
        ]

        return chipsetMap[identifier] ?? "Unknown Chipset"
    }
}

#if os(iOS)
extension UIUserInterfaceIdiom {
    var description: String {
        switch self {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        case .tv: return "Apple TV"
        case .carPlay: return "CarPlay"
        case .mac: return "Mac"
        case .vision: return "Apple Vision Pro"
        @unknown default: return "Unknown"
        }
    }
}
#endif
