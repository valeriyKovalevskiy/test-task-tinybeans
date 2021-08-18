//
//  UITableView+Extension.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import UIKit

extension UITableView {
    
    // ******************************* MARK: - Cell
    
    /// Simplifies cell registration. Xib name must be the same as class name.
    /// - parameter class: Cell's class.
    func registerNib(class: UITableViewCell.Type) {
        register(UINib(nibName: `class`.className, bundle: nil), forCellReuseIdentifier: `class`.className)
    }
    
    /// Simplifies cell dequeue.
    /// - parameter class: Cell's class.
    /// - parameter indexPath: Cell's index path.
    func dequeue<T: UITableViewCell>(_ class: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T
    }
    
    // ******************************* MARK: - Header and Footer
    
    /// Simplifies header/footer registration. Xib name must be the same as class name.
    /// - parameter class: Header or footer class.
    func registerNib(class: UITableViewHeaderFooterView.Type) {
        register(UINib(nibName: `class`.className, bundle: nil), forHeaderFooterViewReuseIdentifier: `class`.className)
    }
    
    /// Simplifies header/footer dequeue.
    /// - parameter class: Header or footer class.
    func dequeue<T: UITableViewHeaderFooterView>(_ class: T.Type) -> T {
        dequeueReusableHeaderFooterView(withIdentifier: T.className) as! T
    }
}
