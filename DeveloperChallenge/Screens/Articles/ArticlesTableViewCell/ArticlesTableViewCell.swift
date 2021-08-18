//
//  ArticlesTableViewCell.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import UIKit

final class ArticlesTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var scoreIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupMinimumHeightConstraint()
    }
    
    // MARK: - Configuration
    func configure(with viewModel: ArticlesTableViewCellViewModel) {
        messageLabel.text = viewModel.message
        authorLabel.text = viewModel.author
        scoreLabel.text = viewModel.score
        
        configureScoreIconImageView(isScoreEqualZero: viewModel.isScoreEqualZero)
    }
    
    // MARK: - Private
    private func setupMinimumHeightConstraint() {
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
    
    private func configureScoreIconImageView(isScoreEqualZero: Bool) {
        let image = isScoreEqualZero ?
            Constants.noValueIcon :
            Constants.hasValueIcon
        
        scoreIconImageView.image = image
    }
}

// MARK: - Constants
fileprivate extension ArticlesTableViewCell {
    enum Constants {
        static let hasValueIcon = UIImage(systemName: "star.fill")
        static let noValueIcon = UIImage(systemName: "star")
    }
}
