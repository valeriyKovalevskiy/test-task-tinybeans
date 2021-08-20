//
//  DownloadProgressView.swift
//  DeveloperChallenge
//
//  Created by Valery Kavaleuski on 8/19/21.
//  Copyright © 2021 Qantas Assure. All rights reserved.
//

import UIKit
import RxSwift

final class DownloadProgressView: UIView {
    private let disposeBag = DisposeBag()
    private var viewModel: DownloadProgressViewModel?

    // MARK: - Outlets
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressView: UIProgressView!
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    // MARK: - Private
    private func setup() {
        if let view = loadViewFromNib() {
            view.frame = self.bounds
            addSubview(view)
        }
        
        setupBackgroundColor()
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: className.self, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        return view
    }
    
    func configure(with viewModel: DownloadProgressViewModel) {
        self.viewModel = viewModel
        
        viewModel.progressLabelText
            .bind(to: progressLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.progress
            .bind(to: progressView.rx.progress)
            .disposed(by: disposeBag)
    }
    
    private func setupBackgroundColor() {
        backgroundColor = .clear
        progressView.backgroundColor = .gray
    }
    
}
