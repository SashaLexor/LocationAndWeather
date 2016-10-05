//
//  AppDelegate.swift
//  LocationAndWeather
//
//  Created by 1024 on 03.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import UIKit
import CoreData

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
        // Override point for customization after application launch.
        
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
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
    
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }


}

