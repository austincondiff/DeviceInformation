//
//  DeviceInformationView.swift
//  DeviceInformation
//
//  Created by Austin Condiff on 1/28/25.
//

import SwiftUI

struct DeviceInformationView: View {
    @ObservedObject var deviceData: DeviceData
    
    var body: some View {
        Section(header: Text("\(deviceData.modelName)")) {
            LabeledContent("Model Name", value: deviceData.modelName)
            LabeledContent("Model Identifier", value: deviceData.modelIdentifier)
            LabeledContent("Chipset", value: deviceData.chipset)
            LabeledContent("Physical Memory", value: "\(deviceData.physicalMemory) GB")
            LabeledContent("Processor Count", value: "\(deviceData.processorCount)")
            
            #if os(macOS)
            LabeledContent("Serial Number", value: deviceData.serialNumber)
            if let battery = deviceData.batteryPercentage {
                LabeledContent("Battery Percentage", value: "\(battery)%")
            }
            #endif
        }
    }
}

struct DeviceInformationView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInformationView(deviceData: DeviceData())
    }
}
