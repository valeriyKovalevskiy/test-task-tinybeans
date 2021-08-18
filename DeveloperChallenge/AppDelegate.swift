//
//  AppDelegate.swift
//  DeveloperChallenge
//
//  Created by Rogerio de Paula Assis on 30/6/17.
//  Copyright © 2017 Tinybeans. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      // Override point for customization after application launch.
      
      cleanup()
      insertInitialDataToDatabase()
      
      return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DeveloperChallenge")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. 
                // You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertInitialDataToDatabase() {
        createItem(identifier: "0", message: "Hello world!", author: "Tim")
        createItem(identifier: "1", message: "Yo!", author: "Rog")
        createItem(identifier: "2", message: "Swifty", author: "Summer")
        createItem(identifier: "3", message: "FooBar", author: "Stephen")
        createItem(identifier: "4", message: "FizzBuzz", author: "Sherif")
        saveContext()
    }
    
    func cleanup() {
        try? FileManager.default.contentsOfDirectory(at: NSPersistentContainer.defaultDirectoryURL(), includingPropertiesForKeys: nil, options: []).forEach(FileManager.default.removeItem)
    }
    
    func createItem(identifier: String, message: String, author: String, date: Date = Date()) {
        let entity = RedditEntity(context: persistentContainer.viewContext)
        entity.identifier = identifier
        entity.message = message
        entity.author = author
        entity.date = date as Date
    }

}

