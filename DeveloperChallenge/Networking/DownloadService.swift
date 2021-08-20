//
//  ArticlesViewModel.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation

protocol Downloadable {
    var previewURL: URL { get }
    var downloaded: Bool { get set }
}

final class DownloadService<T: Downloadable> {

    // MARK: - Variables And Properties
    var activeDownloads: [URL: Download<T>] = [:]
    var downloadsSession: URLSession!
    
    // MARK: - Open
    func cancelDownload(_ item: T) {
        guard let download = activeDownloads[item.previewURL] else {
            return
        }
        
        download.task?.cancel()
        activeDownloads[item.previewURL] = nil
    }
    
    func startDownload(_ item: T) {

        let download = Download<T>(downloadData: item)
        download.task = downloadsSession.downloadTask(with: item.previewURL)
        download.task?.resume()
        download.isDownloading = true
        
        if let url = download.downloadData?.previewURL {
            activeDownloads[url] = download
        }
    }
}
