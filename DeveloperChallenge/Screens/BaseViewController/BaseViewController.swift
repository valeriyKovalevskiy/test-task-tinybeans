//
//  BaseViewController.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/20/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    enum Side {
        case right
        case left
    }
    
    enum BarButtonItem {
        case refresh
        case cancel
        
        var buttonItem: UIButton {
            switch self {
            case .cancel:
                let button = UIButton()
                button.setTitle(Constants.cancelButtonDefaultTitle, for: .normal)
                button.setTitleColor(Constants.defaultBarButtonTintColor, for: .normal)
                button.frame = Constants.defaultBarButtonFrame
                
                return button
            case .refresh:
                let button = UIButton()
                button.setImage(Constants.refreshButtonDefaultImage, for: .normal)
                button.frame = Constants.defaultBarButtonFrame
                button.tintColor = Constants.defaultBarButtonTintColor
                
                return button
            }
        }
    }
    
    func configureBarButtonItem(side: Side,
                                item: BarButtonItem,
                                selector: Selector) {
        let button = item.buttonItem
        button.tintColor = .blue
        button.addTarget(self, action: selector, for: .touchUpInside)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        switch side {
        case .left:
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        case .right:
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
}

// MARK: - Constants
fileprivate extension BaseViewController {
    enum Constants {
        static let cancelButtonDefaultTitle = "Cancel"
        static let refreshButtonDefaultImage = UIImage(systemName: "gobackward")
        static let defaultBarButtonTintColor: UIColor = .blue
        static let defaultBarButtonFrame = CGRect(x: 0, y: 0, width: 16, height: 34)
    }
}
