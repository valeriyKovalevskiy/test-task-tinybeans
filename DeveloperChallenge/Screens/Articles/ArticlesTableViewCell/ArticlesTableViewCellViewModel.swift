//
//  ArticlesTableViewCellViewModel.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation

struct ArticlesTableViewCellViewModel {
    let message: String?
    let author: String?
    let score: String?
    let isScoreEqualZero: Bool
    
    init(model: RedditEntity) {
        self.message = model.message
        self.author = model.author
        self.score = String(model.score)
        self.isScoreEqualZero = model.score == 0
    }
}
