//
//  Logger.swift
//  BluetoothExperiments
//
//  Created by Przemyslaw Blasiak on 30/03/2020.
//  Copyright © 2020 Estimote, Inc. All rights reserved.
//

import Foundation

class Logger {
	
	static var shared = Logger()
	
	private var savedLogs = [String]()
	
	func save(_ log: String) {
		if savedLogs.isEmpty {
			savedLogs.insert("\(Date())--- START ---", at: 0)
		}
		savedLogs.append(log)
	}
	
	func dumpToFile() {
		let dumpedString = dumpToString()
		let logFileName = "Log-\(Date()).txt"
		save(text: dumpedString, toDirectory: documentDirectory(), withFileName: logFileName)
		read(fromDocumentsWithFileName: logFileName) // Debug
	}
	
	func dumpToString() -> String {
		savedLogs.append("\(Date())--- END ---")
		let allLogsString = savedLogs.joined(separator: "\n")
		savedLogs = [String]()
		return allLogsString
	}
	
	private func documentDirectory() -> String {
		return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
	}
	
	private func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
		guard var pathURL = URL(string: path) else {
			return nil
		}
		
		pathURL.appendPathComponent(pathComponent)
		return pathURL.absoluteString
	}
	
	private func read(fromDocumentsWithFileName fileName: String) {
		guard let filePath = self.append(toPath: self.documentDirectory(), withPathComponent: fileName) else {
			return
		}
		
		do {
			let savedString = try String(contentsOfFile: filePath)
			print(savedString)
		} catch {
			print("Error", error)
		}
	}
	
	private func save(text: String, toDirectory directory: String, withFileName fileName: String) {
		guard let filePath = self.append(toPath: directory, withPathComponent: fileName) else {
			return
		}
		
		do {
			try text.write(toFile: filePath,
						   atomically: true,
						   encoding: .utf8)
			print("Save successful")
		} catch {
			print("Error", error)
		}
	}
}
