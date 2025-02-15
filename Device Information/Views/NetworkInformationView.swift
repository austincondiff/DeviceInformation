//
//  NetworkInformationView.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import SwiftUI

struct NetworkInformationView: View {
    @StateObject private var networkInfo = NetworkInformationData()
    
    var body: some View {
        Section(header: Text("Network Information")) {
            LabeledContent("Host Name", value: networkInfo.hostName)
            
            LabeledContent("Connection Status") {
                Text(networkInfo.isConnectedToNetwork ? "Connected" : "Disconnected")
                    .foregroundColor(networkInfo.isConnectedToNetwork ? .green : .red)
            }
            
            LabeledContent("Connection Type", value: networkInfo.connectionType)
            LabeledContent("Interface Name", value: networkInfo.interfaceName)
#if os(macOS)
            LabeledContent("MAC Address", value: networkInfo.macAddress)
#endif
            LabeledContent("IPv4 Address", value: networkInfo.ipv4Address)
            LabeledContent("IPv6 Address", value: networkInfo.ipv6Address)
        }
    }
}

struct NetworkInformationView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkInformationView()
    }
} 
