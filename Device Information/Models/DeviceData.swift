//
//  DeviceData.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import Foundation
#if os(macOS)
import AppKit
#endif

class DeviceData: ObservableObject {
    @Published var modelName = DeviceInfo.getSimpleDeviceName()
    @Published var modelIdentifier = DeviceInfo.getDeviceIdentifier()
    @Published var chipset = DeviceInfo.getChipset()
    @Published var operatingSystem = ProcessInfo.processInfo.operatingSystemVersionString
    @Published var hostName = ProcessInfo.processInfo.hostName
    @Published var physicalMemory = ProcessInfo.processInfo.physicalMemory / (1024 * 1024 * 1024)
    @Published var processorCount = ProcessInfo.processInfo.processorCount
    @Published var bootTime = DeviceInfo.getBootTime()
    @Published var systemUptime = DeviceInfo.formattedUptime()
    @Published var localIPv4Address: String?
    @Published var localIPv6Address: String?
#if os(macOS)
    @Published var serialNumber = DeviceInfo.getSerialNumber()
    @Published var batteryPercentage: Int? = DeviceInfo.getBatteryPercentage()
    @Published var fullUserName = ProcessInfo.processInfo.fullUserName
    @Published var username = ProcessInfo.processInfo.userName
    @Published var screens = NSScreen.screens
#endif

    init() {
        let (ipv4, ipv6) = DeviceInfo.getLocalIPAddresses()
        self.localIPv4Address = ipv4
        self.localIPv6Address = ipv6
    }

    func startAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.refresh()
        }
    }

    func refresh() {
        DispatchQueue.main.async {
            self.systemUptime = DeviceInfo.formattedUptime()
            let (ipv4, ipv6) = DeviceInfo.getLocalIPAddresses()
            self.localIPv4Address = ipv4
            self.localIPv6Address = ipv6
#if os(macOS)
            self.batteryPercentage = DeviceInfo.getBatteryPercentage()
            self.screens = NSScreen.screens
#endif
        }
    }
}
