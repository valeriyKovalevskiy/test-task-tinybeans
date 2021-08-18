//
//  ArticlesViewModel.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SSZipArchive

final class ArticlesViewModel {
    
    var reddits = [RedditEntity]()

    init() {
        
    }
    
    func fetchData() {
        do {
            let redditsResponse: [RedditEntity] = try getContext().fetch(RedditEntity.fetchRequest())
            let sortedByDateReddits = redditsResponse.sorted { $0.date ?? Date() < $1.date ?? Date() }
            let sortedByScoreReddits = sortedByDateReddits.sorted { $0.score > $1.score }
            
            reddits = sortedByScoreReddits
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchReddits(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://tinybeans-artifacts.s3.amazonaws.com/ios/developer-challenge/reddit/reddit.zip")!
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
//            self.progressView.progress = 0.5
            
            if let locationURL = location {
                let destination = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("unarchived")
                
                if SSZipArchive.unzipFile(atPath: locationURL.path, toDestination: destination.path) {
                    
                    DispatchQueue.main.async {
                        
                        let contents = try! FileManager.default.contentsOfDirectory(at: destination, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
                        
                        contents.forEach { url in
                            if let data = try? Data(contentsOf: url),
                               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any],
                               let jsonData = json["data"] as? [AnyHashable: Any],
                               let items = jsonData["children"] as? [[AnyHashable: Any]] {
                                
                                items.forEach { jsonDict in
                                    if let item = jsonDict["data"] as? [AnyHashable: Any],
                                       let message = item["selftext"] as? String,
                                       let identifier = item["id"] as? String,
                                       let score = item["score"] as? Int16,
                                       let createdAt = item["created"] as? Int,
                                       let author = item["author"] as? String {
                                        
                                        let newEntity = RedditEntity(context: getContext())
                                        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
                                        newEntity.score = score
                                        newEntity.identifier = identifier
                                        newEntity.author = author
                                        newEntity.message = message
                                        newEntity.date = date
                                    }
                                }
                                
                                
                            }
                        }

                        saveContext()
                        completion(true)
                    }
                    
                }
                
            }
        }
        
        task.resume()
    }
}

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
