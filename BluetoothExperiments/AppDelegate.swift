//
//  AppDelegate.swift
//  BluetoothExperiments
//
//  Created by Przemyslaw Blasiak on 27/03/2020.
//  Copyright © 2020 Estimote, Inc. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.registerBackgroundTasks()
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
}

extension AppDelegate {
	
	public static let refreshBackgroundTaskIdentifier = "com.estimote.backgroundRefresh"
    public static let processingBackgroundTaskIdentifier = "com.estimote.backgroundProcessing"
	
	// Note: Using values higher than 30 seconds will result in the system killing the app
    public static let backgroundRunningTimeout: TimeInterval = 3
	
	func registerBackgroundTasks() {
        let taskIdentifiers: [String] = [
            AppDelegate.refreshBackgroundTaskIdentifier,
            AppDelegate.processingBackgroundTaskIdentifier
        ]
        taskIdentifiers.forEach { identifier in
            let success = BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil
            ) { task in
				Logger.shared.save("Background task started: \(identifier)")
				self.handleBackground(task: task)
            }
            Logger.shared.save("Background task registered: \(identifier), with success: \(success)")
        }
    }
	
	func handleBackground(task: BGTask) {
        switch task.identifier {
            case AppDelegate.refreshBackgroundTaskIdentifier:
                guard let task = task as? BGAppRefreshTask else { break }
                handleBackgroundAppRefresh(task: task)
            case AppDelegate.processingBackgroundTaskIdentifier:
                guard let task = task as? BGProcessingTask else { break }
                handleBackgroundProcessing(task: task)
            default:
                task.setTaskCompleted(success: false)
        }
    }
	
	func handleBackgroundAppRefresh(task: BGAppRefreshTask) {
        // Schedule a new task already
        scheduleBackgroundAppRefreshTask()
		
        // TODO: Sync any data with Cloud here.
    }
	
	func handleBackgroundProcessing(task: BGProcessingTask) {
        scheduleBackgroundProcessingTask()
        stayAwake(with: task)
    }
    
    func stayAwake(with task: BGTask) {
        DispatchQueue.main.asyncAfter(deadline: .now() + AppDelegate.backgroundRunningTimeout) {
			Logger.shared.save("Background task ended: \(task.identifier)")
            task.setTaskCompleted(success: true)
        }
    }
	
	func scheduleBackgroundTasks() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        self.scheduleBackgroundAppRefreshTask()
        self.scheduleBackgroundProcessingTask()
    }
    
    func scheduleBackgroundAppRefreshTask() {
        let request = BGAppRefreshTaskRequest(identifier: AppDelegate.refreshBackgroundTaskIdentifier)
        request.earliestBeginDate = nil
        self.submitTask(request: request)
    }
    
    func scheduleBackgroundProcessingTask() {
		let request = BGProcessingTaskRequest(identifier: AppDelegate.processingBackgroundTaskIdentifier)
		request.requiresNetworkConnectivity = false
		request.requiresExternalPower = false
		request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
		self.submitTask(request: request)
    }
	
	func submitTask(request: BGTaskRequest) {
        do {
            try BGTaskScheduler.shared.submit(request)
			Logger.shared.save("Background task requested: \(request.description)")
        } catch {
			Logger.shared.save("Background task requested: \(request.description), failed: \(error.localizedDescription)")
        }
    }
}
