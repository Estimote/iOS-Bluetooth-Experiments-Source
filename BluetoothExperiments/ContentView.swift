//
//  ContentView.swift
//  BluetoothExperiments
//
//  Created by Przemyslaw Blasiak on 27/03/2020.
//  Copyright © 2020 Estimote, Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var bluetoothManager = BluetoothManager()
	
    var body: some View {
		VStack(spacing: 20.0) {
			Spacer()
			Toggle(isOn: $bluetoothManager.isRunning) {
				Text("Running")
			}
			Text(bluetoothManager.scanningStatus)
			Text(bluetoothManager.advertisingStatus)
			Text("Current log:\n \(bluetoothManager.currentLog)")
			Spacer()
			Button(action: {
				Logger.shared.dumpToFile()
			}) { Text("Dump logs to file") }
			Button(action: {
				Logger.shared.clear()
			}) { Text("Clear logs") }
		}
		.font(Font.system(size: 25, weight: .medium, design: .default))
		.buttonStyle(DefaultButtonStyle())
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
