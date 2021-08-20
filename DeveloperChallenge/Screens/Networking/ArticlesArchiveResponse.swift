//
//  ArticlesArchiveModel.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation


final class ArticlesArchiveModel: Downloadable {
    //
    // MARK: - Constants
    //
    let index: Int
    let name: String
    let previewURL: URL
    
    //
    // MARK: - Variables And Properties
    //
    var downloaded = false
    
    //
    // MARK: - Initialization
    //
    init(name: String, previewURL: URL, index: Int) {
        self.name = name
        self.previewURL = previewURL
        self.index = index
    }
}

extension ArticlesArchiveModel {
    fileprivate static let previewURL = URL(string: "https://tinybeans-artifacts.s3.amazonaws.com/ios/developer-challenge/reddit/reddit.zip")!
    static let reddits = ArticlesArchiveModel(name: "reddits",
                                              previewURL: previewURL,
                                              index: 1)

}
