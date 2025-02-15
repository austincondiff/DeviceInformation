//
//  DisplayInformationView.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct DisplayInformationView: View {
    #if os(macOS)
    let screen: NSScreen
    private let displayInfo: DisplayInformationData
    
    init(screen: NSScreen) {
        self.screen = screen
        self.displayInfo = DisplayInformationData(screen: screen)
    }
    
    var body: some View {
        Section(header: Text("\(screen.localizedName)")) {
            LabeledContent("Type", value: displayInfo.type)
            LabeledContent("Resolution", value: displayInfo.resolution)
            LabeledContent("Scale Factor", value: displayInfo.scaleFactor)
            if let refreshRate = displayInfo.refreshRate {
                LabeledContent("Refresh Rate", value: "\(refreshRate) Hz")
            }
            if let ppi = displayInfo.pixelDensity {
                LabeledContent("Pixel Density", value: "\(ppi) PPI")
            }
        }
    }
    #else
    private let displayInfo = DisplayInformationData()
    
    var body: some View {
        Section(header: Text("Display Information")) {
            LabeledContent("Resolution", value: displayInfo.resolution)
            LabeledContent("Scale Factor", value: displayInfo.scaleFactor)
            if let refreshRate = displayInfo.refreshRate {
                LabeledContent("Refresh Rate", value: "\(refreshRate) Hz")
            }
            if let ppi = displayInfo.pixelDensity {
                LabeledContent("Pixel Density", value: "\(ppi) PPI")
            }
        }
    }
    #endif
}

#if os(macOS)
struct DisplayInformationView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayInformationView(screen: NSScreen.main!)
    }
}
#else
struct DisplayInformationView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayInformationView()
    }
}
#endif
