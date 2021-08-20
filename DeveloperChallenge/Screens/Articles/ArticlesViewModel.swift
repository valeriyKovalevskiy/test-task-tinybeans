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
import RxSwift
import RxCocoa

final class ArticlesViewModel: NSObject {
    enum LoadingError {
        case badURLError
        case unzipError
        case invalidStateError
        case fetchFromDatabaseError
    }
    
    enum LoadingState: Equatable {
        case ready
        case loading
        case error(LoadingError)
    }
    
    private let disposeBag = DisposeBag()
    private var downloadService = DownloadService<ArticlesArchiveModel>()
    private(set) var reddits = BehaviorRelay<[RedditEntity]>(value: [])
    private(set) var progress = BehaviorRelay<Float>(value: 0.0)
    private(set) var loadingState = BehaviorRelay<LoadingState>(value: .ready)
    
    private lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.default
        
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override init() {
        super.init()
        // TODO: - Bindings and handle states
        // TODO: - Handle persistence
        downloadService.downloadsSession = downloadsSession
    }
    
    func fetchData() {
        do {
            let redditsResponse: [RedditEntity] = try getContext().fetch(RedditEntity.fetchRequest())
            let sortedByDateReddits = redditsResponse.sorted { $0.date ?? Date() < $1.date ?? Date() }
            let sortedByScoreReddits = sortedByDateReddits.sorted { $0.score > $1.score }
            
            reddits.accept(sortedByScoreReddits)
        } catch {
            loadingState.accept(.error(.fetchFromDatabaseError))
        }
    }

    func cancelDownload() {
        guard loadingState.value == .loading else {
            loadingState.accept(.error(.invalidStateError))
            return
        }
        
        loadingState.accept(.ready)
        downloadService.cancelDownload(.reddits)
    }
    
    func downloadData() {
        guard loadingState.value == .ready else {
            loadingState.accept(.error(.invalidStateError))
            return
        }
        
        progress.accept(0.0)
        loadingState.accept(.loading)
        downloadService.startDownload(.reddits)
    }
    
    private func unzipResponseAt(path location: URL, to destination: URL) {
        guard SSZipArchive.unzipFile(atPath: location.path, toDestination: destination.path) else {
            loadingState.accept(.error(.unzipError))
            return
        }
        
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
            
            self.fetchData()
            saveContext()
            self.loadingState.accept(.ready)
        }
    }
}

// MARK: - URLSession download delegate methods
extension ArticlesViewModel: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else {
            loadingState.accept(.error(.badURLError))
            return
        }
        
        let download = downloadService.activeDownloads[sourceURL]
        download?.downloadData?.downloaded = true
        downloadService.activeDownloads[sourceURL] = nil
        unzipResponseAt(path: location, to: Constants.destinationURL)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url,
              let download = downloadService.activeDownloads[url]
        else {
            loadingState.accept(.error(.badURLError))
            return
        }
        
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progress.accept(download.progress)
    }
}

// MARK: - Constants
fileprivate extension ArticlesViewModel {
    enum Constants {
        static let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("unarchived")
    }
}
