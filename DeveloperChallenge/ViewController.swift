//
//  ViewController.swift
//  DeveloperChallenge
//
//  Created by Rogerio de Paula Assis on 30/6/17.
//  Copyright © 2017 Tinybeans. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SSZipArchive

func getAppDelegate() -> AppDelegate {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    return delegate
}

func saveContext() {
    getAppDelegate().saveContext()
}

func getContext() -> NSManagedObjectContext {
    return getAppDelegate().persistentContainer.viewContext
}

class ViewController: UITableViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var reddits = [RedditEntity]()
    let progressView = UIProgressView(progressViewStyle: .bar)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchData()
        
        navigationItem.title = "Reddit"
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
        progressView.backgroundColor = UIColor.gray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func refreshData() {
        self.progressView.progress = 0
        tableView.tableHeaderView = progressView

        let url = URL(string: "https://tinybeans-artifacts.s3.amazonaws.com/ios/developer-challenge/reddit/reddit.zip")!
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            self.progressView.progress = 0.5

            if let locationURL = location {
                let destination = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("unarchived")
                
                if SSZipArchive.unzipFile(atPath: locationURL.path, toDestination: destination.path) {
                    
                    DispatchQueue.main.async {
                        self.progressView.progress = 0.7
                        
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
                                        let createdAt = item["created"] as? Int,
                                        let author = item["author"] as? String {
                                        let newEntity = RedditEntity(context: getContext())
                                        newEntity.identifier = identifier
                                        newEntity.author = author
                                        newEntity.message = message
                                        let date = Date(timeIntervalSince1970: TimeInterval(createdAt))
                                        newEntity.date = date
                                    }
                                }
                                
                                
                            }
                        }
                        
                        self.progressView.setProgress(1, animated: true)
                        
                        self.fetchData()
                        self.tableView.reloadData()
                        self.tableView.tableHeaderView = nil

                        saveContext()
                    }
                    
                }

            }
        }

        task.resume()
    }
    
    func fetchData() {
        reddits = try! getContext().fetch(RedditEntity.fetchRequest())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RedditCell", for: indexPath)
        cell.textLabel?.text = reddits[indexPath.row].message
        cell.detailTextLabel?.text = reddits[indexPath.row].author
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reddits.count
    }
}

