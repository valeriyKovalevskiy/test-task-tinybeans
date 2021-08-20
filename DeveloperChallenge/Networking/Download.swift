//
//  ArticlesViewModel.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation

final class Download<T> {
    var isDownloading = false
    var progress: Float = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var downloadData: T?
    
    init(downloadData: T?) {
        self.downloadData = downloadData
    }
}
