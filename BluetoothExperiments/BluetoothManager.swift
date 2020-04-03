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

class BluetoothManager: NSObject, ObservableObject {
	
	@Published var scanningStatus: String
	@Published var advertisingStatus: String
	@Published var currentLog: String
	@Published var isRunning: Bool {
		didSet {
			guard isRunning != oldValue else { return }
			isRunning ? start() : stop()
		}
	}
	
	private var dispatchQueue = DispatchQueue(label: "bluetooth-manager-queue")
	private var centralManager: CBCentralManager?
	private var peripheralManager: CBPeripheralManager?
	
	override init() {
		self.scanningStatus = "Idle."
		self.advertisingStatus = "Idle."
		self.currentLog = ""
		self.isRunning = false
		super.init()
	}
	
	func start() {
		centralManager = CBCentralManager(delegate: self, queue: dispatchQueue)
		peripheralManager = CBPeripheralManager(delegate: self, queue: dispatchQueue)
		
		isRunning = true
	}
	
	func stop() {
		centralManager?.stopScan()
		centralManager?.delegate = nil
		peripheralManager?.stopAdvertising()
		peripheralManager?.delegate = nil
		
		advertisingStatus = "Idle."
		scanningStatus = "Idle."
		
		isRunning = false
	}
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
	func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
		DispatchQueue.main.async {
			if (peripheral.state == .poweredOn) {
				self.peripheralManager?.add(PhoneService.service)
				self.peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey: "TestName", CBAdvertisementDataServiceUUIDsKey: [PhoneService.serviceUUID]]) // TODO: Add data using `CBAdvertisementDataServiceDataKey`.
				
				self.advertisingStatus = "Advertising."
			} else {
				self.advertisingStatus = "Failed to advertise."
			}
		}
	}
	
	func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
		DispatchQueue.main.async {
			print("peripheralManagerDidStartAdvertising")
		}
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		DispatchQueue.main.async {
			if central.state == .poweredOn {
				self.centralManager?.scanForPeripherals(withServices: [PhoneService.serviceUUID], options: nil) // TODO: Test if the "duplicates" option impacts background //
				self.scanningStatus = "Scanning."
			} else {
				self.scanningStatus = "Failed to scan."
			}
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		DispatchQueue.main.async {
			let appState = UIApplication.currentStateName()
			let localName = advertisementData[CBAdvertisementDataLocalNameKey] ?? "<no name>"
			let serviceUUIDs = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? Array<CBUUID>) ?? [CBUUID]()
			let overflowServiceUUIDs = (advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? Array<CBUUID>) ?? [CBUUID]()
			let log = "\(Date()):\(appState);\(localName);\(serviceUUIDs);\(overflowServiceUUIDs);\(RSSI)"
			self.currentLog = log
			print(log)
			Logger.shared.save(log)
			
			self.centralManager?.stopScan()
			self.centralManager?.scanForPeripherals(withServices: [PhoneService.serviceUUID]) // TODO: Test if the "duplicates" option impacts background
		}
	}
}

extension BluetoothManager {
	class PhoneService: NSObject {
        public static let serviceUUID = CBUUID(string: "EC01")
		
		// TODO: Characteristics
//		public static let characteristicUUID = CBUUID(string: "1F04D160-C908-40E0-9903-78E5EA14A7B6")
//
//		public static var characteristic: CBMutableCharacteristic {
//			return CBMutableCharacteristic(type: characteristicUUID, properties: [.read], value: "TestValue".data(using: .utf8), permissions: [.readable])
//		}

		public static var service: CBMutableService {
			let phoneService = CBMutableService(type: serviceUUID, primary: true)
//			phoneService.characteristics = [characteristic] // TODO: Characteristics
			return phoneService
		}
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
