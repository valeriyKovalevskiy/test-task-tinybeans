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
    // MARK: - Enums
    private enum LoadingError {
        case badURLError
        case unzipError
        case invalidStateError
        case fetchFromDatabaseError
        case `default`
    }
    
    private enum LoadingState: Equatable {
        case ready
        case loading
        case error(LoadingError)
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var downloadService = DownloadService<ArticlesArchiveModel>()
    private var loadingState = BehaviorRelay<LoadingState>(value: .ready)
    private var thrownError = BehaviorRelay<LoadingError>(value: .default)
    private lazy var downloadsSession: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - UI observables
    private(set) var isDownloading = BehaviorRelay<Bool>(value: false)
    private(set) var isReady = BehaviorRelay<Bool>(value: true)
    private(set) var shouldUpdateLayout = BehaviorRelay<Bool>(value: false)
    private(set) var progressValue = BehaviorRelay<Float>(value: 0.0)
    private(set) var dataSource = BehaviorRelay<[RedditEntity]>(value: [])

    // MARK: - Init
    override init() {
        super.init()

        setupDownloadService()
        setupBindings()
    }
    
    // MARK: - Private
    private func setupDownloadService() {
        downloadService.downloadsSession = downloadsSession
    }
    
    private func setupBindings() {
        dataSource
            .map { _ in true }
            .bind(to: shouldUpdateLayout)
            .disposed(by: disposeBag)
        
        loadingState
            .map { $0 == .loading }
            .bind(to: isDownloading)
            .disposed(by: disposeBag)
        
        loadingState
            .map { $0 == .ready }
            .bind(to: isReady)
            .disposed(by: disposeBag)
        
        loadingState
            .map { state -> LoadingError in
                switch state {
                case .error(let error):
                    return error
                default:
                    return .default
                }
            }
            .bind(to: thrownError)
            .disposed(by: disposeBag)
        
        
        thrownError
            .filter { $0 != .default }
            .subscribe(onNext: {
                
                // TODO: - Bind or subscribe for some error texts changes
                debugPrint($0)
            })
            .disposed(by: disposeBag)
    }
    // TODO: - Handle persistence

    // MARK: - Open
    func fetchData() {
        do {
            let redditsResponse: [RedditEntity] = try getContext().fetch(RedditEntity.fetchRequest())
            let sortedByDateReddits = redditsResponse.sorted { $0.date ?? Date() < $1.date ?? Date() }
            let sortedByScoreReddits = sortedByDateReddits.sorted { $0.score > $1.score }
            
            dataSource.accept(sortedByScoreReddits)
        } catch {
            loadingState.accept(.error(.fetchFromDatabaseError))
        }
    }

    private func sortDataSource(_ datasource: [RedditEntity]) -> [RedditEntity] {
        []
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
        
        progressValue.accept(0.0)
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
            
            contents[0...1].forEach { url in
                if let data = try? Data(contentsOf: url),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any],
                   let jsonData = json["data"] as? [AnyHashable: Any],
                   let items = jsonData["children"] as? [[AnyHashable: Any]] {
                    
                    items[0...1].forEach { jsonDict in
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
        progressValue.accept(download.progress)
    }
}

// MARK: - Constants
fileprivate extension ArticlesViewModel {
    enum Constants {
        static let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("unarchived")
    }
}
