//
//  AppDelegate.swift
//  LocationAndWeather
//
//  Created by 1024 on 03.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import UIKit
import CoreData


// Custom Core Dta Error notification & global func for posting this notification

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: Error) {
    print("Core Data fatal error: \(error)")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Create an NSURL object pointing at "DataModel.momd" file in the app bundle (xdatamodel -> momd)
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }
        // Create an NSManagedObjectModel from that URL. This object represents the data model during runtime.
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        // Create an NSURL object pointing at the DataStore.sqlite file
        let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        let documentsDirectory = urls[0]
        let storeURL = documentsDirectory.appendingPathComponent("DataStore.sqlite")
        print(storeURL)
        do {
            // This object is in charge of the SQLite database.
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            // Add the SQLite database to the store coordinator.
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            // Create the NSManagedObjectContext object and return it.
            let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {
            fatalCoreDataError(error: error)
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        }
    }()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Send managedObjectContext to controllers
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarControllers = tabBarController.viewControllers {
            let locationController = tabBarControllers[0] as! LocationViewController
            locationController.managedObjectContext = managedObjectContext
            
            let secondNavigationController = tabBarControllers[1] as! UINavigationController
            let historyController = secondNavigationController.topViewController as! HistoryViewController
            historyController.managedObjectContext = managedObjectContext
        }
        return true
    }
    
    // Add observer for custom Core Data Error
    func listenForFatalCoreDataNotification() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil, queue: OperationQueue.main, using: {
            notification in
            let alert = UIAlertController(title: "Internal error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            })
            alert.addAction(action)
            self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
        })
    }
    
    // Get view for pesenting Aller
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {    }
    
    func applicationWillTerminate(_ application: UIApplication) {    }
    
    
}

