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
		VStack {
			Text(bluetoothManager.status)
			Text(bluetoothManager.discoveredDevice)
		}
		.font(Font.system(size: 25, weight: .medium, design: .default))
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
