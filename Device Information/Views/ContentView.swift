//
//  ContentView.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import SwiftUI
import Foundation
#if os(macOS)
import IOKit.ps
import AppKit
#endif
import SystemConfiguration

struct ContentView: View {
    @StateObject private var deviceData = DeviceData()

    var body: some View {
        contentList
    }

    private var contentList: some View {
        Form {
            DeviceInformationView(deviceData: deviceData)
        
            SystemInformationView(deviceData: deviceData)
            
            NetworkInformationView()
            
            #if os(macOS)
            ForEach(deviceData.screens, id: \.self) { screen in
                DisplayInformationView(screen: screen)
            }
            #else
            DisplayInformationView()
            #endif
        }
        .formStyle(.grouped)
        .onAppear {
            deviceData.startAutoRefresh()
        }
//        #if os(iOS)
//        .navigationTitle("Device Info")
//        #endif
    }
}

#Preview {
    ContentView()
}
