//
//  ClassName.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/18/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation

/// Allows to get class name string
protocol ClassName {
    /// Class name string
    @nonobjc static var className: String { get }
    
    /// Class name string
    @nonobjc var className: String { get }
}

extension ClassName {
    @nonobjc static var className: String {
        String(describing: self)
    }
    
    @nonobjc var className: String {
        String(describing: type(of: self))
    }
}

extension NSObject: ClassName {}
