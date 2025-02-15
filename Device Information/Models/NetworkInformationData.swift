//
//  NetworkInformationData.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import Foundation
import Network
#if os(macOS)
import IOKit
import IOKit.network
#endif

class NetworkInformationData: ObservableObject {
    @Published var isConnectedToNetwork: Bool = false
    @Published var ipv4Address: String = "Unknown"
    @Published var ipv6Address: String = "Unknown"
    @Published var interfaceName: String = "Unknown"
    @Published var connectionType: String = "Unknown"
    @Published var hostName: String = "Unknown"
    @Published var macAddress: String = "Unknown"

    private var monitor: NWPathMonitor?
    
    init() {
        hostName = ProcessInfo.processInfo.hostName
        startMonitoring()
        getIPAddresses()
#if os(macOS)
        getMacAddress()
#endif
    }
#if os(macOS)
    private func getMacAddress() {
           let matchingDict = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
           matchingDict["IOPropertyMatch"] = ["IOPrimaryInterface": true]
           
           var iterator: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator) == KERN_SUCCESS {
               defer { IOObjectRelease(iterator) }
               
               var service = IOIteratorNext(iterator)
               while service != 0 {
                   defer {
                       IOObjectRelease(service)
                       service = IOIteratorNext(iterator)
                   }
                   
                   var parentService: io_object_t = 0
                   if IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService) == KERN_SUCCESS {
                       defer { IOObjectRelease(parentService) }
                       
                       if let macData = IORegistryEntryCreateCFProperty(parentService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? Data {
                           let macAddress = macData.map { String(format: "%02x", $0) }.joined(separator: ":")
                           DispatchQueue.main.async {
                               self.macAddress = macAddress.uppercased()
                           }
                           break
                       }
                   }
               }
           }
       }
#endif
    private func startMonitoring() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnectedToNetwork = path.status == .satisfied
                self?.updateConnectionType(path: path)
                self?.getIPAddresses()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)
    }
    
    private func updateConnectionType(path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = "WiFi"
        } else if path.usesInterfaceType(.cellular) {
            connectionType = "Cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = "Ethernet"
        } else {
            connectionType = "Unknown"
        }
    }
    
    private func getIPAddresses() {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return
        }
        defer { freeifaddrs(ifaddr) }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if let name = interface?.ifa_name {
                let interfaceName = String(cString: name)
                if interfaceName.contains("en") || interfaceName.contains("pdp_ip") {
                    self.interfaceName = interfaceName
                }
            }
            
            if addrFamily == UInt8(AF_INET) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface?.ifa_addr,
                           socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                           &hostname,
                           socklen_t(hostname.count),
                           nil,
                           0,
                           NI_NUMERICHOST)
                if let address = String(cString: hostname, encoding: .utf8) {
                    ipv4Address = address
                }
            } else if addrFamily == UInt8(AF_INET6) {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface?.ifa_addr,
                           socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                           &hostname,
                           socklen_t(hostname.count),
                           nil,
                           0,
                           NI_NUMERICHOST)
                if let address = String(cString: hostname, encoding: .utf8) {
                    ipv6Address = address
                }
            }
        }
    }
    
    deinit {
        monitor?.cancel()
    }
} 
