//
//  DownloadProgressViewModel.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/19/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct DownloadProgressViewModel {
    private let disposeBag = DisposeBag()
    
    private(set) var progress = BehaviorRelay<Float>(value: 0.0)
    private(set) var progressLabelText = BehaviorRelay<String>(value: "")
    
    // MARK: - Init
    init() {
        setupBindings()
    }
    
    // MARK: - Private
    private func setupBindings() {
        progress
            .map { Int($0 * 100) }
            .map { "progress: \($0) %" }
            .bind(to: progressLabelText)
            .disposed(by: disposeBag)
    }
}
