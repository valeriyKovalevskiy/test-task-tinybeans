//
//  AppDelegate+CoreData.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import UIKit
import CoreData

// TODO: - Move to core data layer
func getAppDelegate() -> AppDelegate {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    return delegate
}

func saveContext() {
    getAppDelegate().saveContext()
}

func getContext() -> NSManagedObjectContext {
    getAppDelegate().persistentContainer.viewContext
}

extension AppDelegate {
    
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
