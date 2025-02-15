//
//  SystemInformationView.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import SwiftUI

struct SystemInformationView: View {
    @ObservedObject var deviceData: DeviceData
    
    var body: some View {
        Section(header: Text("System Information")) {
            LabeledContent("Operating System", value: deviceData.operatingSystem)
            LabeledContent("Boot Time", value: deviceData.bootTime)
            LabeledContent("System Uptime", value: deviceData.systemUptime)
            
            #if os(macOS)
            LabeledContent("User's Full Name", value: deviceData.fullUserName)
            LabeledContent("Username", value: deviceData.username)
            #endif
        }
    }
}

struct SystemInformationView_Previews: PreviewProvider {
    static var previews: some View {
        SystemInformationView(deviceData: DeviceData())
    }
}
