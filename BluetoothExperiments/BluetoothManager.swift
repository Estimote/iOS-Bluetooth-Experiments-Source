//
//  BluetoothManager.swift
//  BluetoothExperiments
//
//  Created by Przemyslaw Blasiak on 27/03/2020.
//  Copyright © 2020 Estimote, Inc. All rights reserved.
//

import Combine
import Foundation
import CoreBluetooth
import UIKit
import Speech
import AVKit

class BluetoothManager: NSObject, ObservableObject {
	
	@Published var status: String
	@Published var discoveredDevice: String
	
	private var centralManager: CBCentralManager!
	private var peripheralManager: CBPeripheralManager!
    private var peripheral: CBPeripheral!
	private let phonePeripheral = PhonePeripheral()
	
	override init() {
		self.status = "Idle."
		self.discoveredDevice = ""
		super.init()
		
		self.start()
	}
	
	func start() {
		centralManager = CBCentralManager(delegate: self, queue: nil)
		peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
	}
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
	func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		if (peripheral.state == .poweredOn) {
			peripheralManager.add(phonePeripheral.service)
			peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "PrzemekTest", CBAdvertisementDataServiceUUIDsKey: [phonePeripheral.serviceUUID]])
			
			status = status + "\nAdvertising."
		} else {
			status = status + "\nFailed to advertise."
		}
	}
	
	func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
		print("peripheralManagerDidStartAdvertising")
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		if central.state == .poweredOn {
			centralManager.scanForPeripherals(withServices: [phonePeripheral.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
			status = status + "\nScanning."
		} else {
			status = status + "\nFailed to scan."
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		discoveredDevice = "\n\(peripheral.name ?? "Unknown"), rssi: \(RSSI)."
		let log = "\(Date()):\(UIApplication.currentStateName());\(advertisementData[CBAdvertisementDataLocalNameKey] ?? "n/a");\(advertisementData[CBAdvertisementDataServiceUUIDsKey] as! Array<CBUUID>)"
		Logger.shared.save(log)
	}
}

extension BluetoothManager {
	class PhonePeripheral: NSObject {
        let serviceUUID = CBUUID(string: "44CCDDA1-9E01-4A2B-A707-65C4B5380B97")
		let testCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "EF04D160-C908-40E0-9903-78E5EA14A7B6"), properties: [.read], value: "TestValue".data(using: .utf8), permissions: [.readable])
		lazy var service: CBMutableService = {
			let phoneService = CBMutableService(type: serviceUUID, primary: true)
			phoneService.characteristics = [testCharacteristic]
			return phoneService
		}()
    }
}

extension UIApplication {
	static func currentStateName() -> String {
		switch UIApplication.shared.applicationState {
		case .active: return "Active"
		case .inactive: return "Inactive"
		case .background: return "Background"
		default: return "Unknown"
		}
	}
}
