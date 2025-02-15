//
//  DeviceInformationApp.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//  Description: Main app entry point that sets up the navigation and window configuration
//

import SwiftUI

@main
struct DeviceInformationApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
#if os(iOS)
                    .navigationTitle("Device Information")
                    .navigationBarTitleDisplayMode(.large)
#else
                    .frame(minWidth: 400, idealWidth: 600, maxWidth: 600)
#endif
            }

        }
        .windowResizability(.contentSize)
    }
}
