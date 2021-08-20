//
//  ViewController.swift
//  DeveloperChallenge
//
//  Created by Rogerio de Paula Assis on 30/6/17.
//  Copyright © 2017 Tinybeans. All rights reserved.
//

import UIKit
import RxSwift

final class ArticlesViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    
    private var viewModel = ArticlesViewModel()
    
    
    // MARK: - Outlets
    @IBOutlet private var downloadProgressView: DownloadProgressView!
    @IBOutlet private var downloadProgressViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchData()
        setupBindings()
        setupTableView()
        setupDownloadProgressView()
        setupNavigationItems()
    }
    
    // MARK: - Private
    private func setupBindings() {
        viewModel.shouldUpdateLayout
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.isDownloading
            .observeOn(MainScheduler.instance)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.showDownloadProgressViewWithAnimation()
                self?.configureBarButtonItem(side: .right,
                                             item: .cancel,
                                             selector: #selector(self?.cancelDownload))
            })
            .disposed(by: disposeBag)
        
        viewModel.isReady
            .observeOn(MainScheduler.instance)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.hideDownloadProgressViewWithAnimation()
                self?.configureBarButtonItem(side: .right,
                                             item: .refresh,
                                             selector: #selector(self?.refreshData))
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(class: ArticlesTableViewCell.self)
    }
    
    private func setupDownloadProgressView() {
        let downloadProgressViewModel = DownloadProgressViewModel()
        
        viewModel.progressValue
            .bind(to: downloadProgressViewModel.progress)
            .disposed(by: disposeBag)
        
        downloadProgressView.configure(with: downloadProgressViewModel)
    }
    
    private func setupNavigationItems() {
        navigationItem.title = Constants.navigationTitle
        configureBarButtonItem(side: .right,
                               item: .refresh,
                               selector: #selector(refreshData))
    }
    
    @objc
    private func cancelDownload() {
        viewModel.cancelDownload()
    }
    
    @objc
    private func refreshData() {
        viewModel.downloadData()
    }
    
    private func showDownloadProgressViewWithAnimation() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.downloadProgressViewHeightConstraint.constant = Constants.progressViewActiveHeightConstraint
            self?.view.layoutIfNeeded()
        }
    }
    
    private func hideDownloadProgressViewWithAnimation() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.downloadProgressViewHeightConstraint.constant = Constants.progressViewInactiveHeightConstraint
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - TableView delegate methods
extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ArticlesTableViewCell.self, for: indexPath)
        let model = viewModel.dataSource.value[indexPath.row]
        let viewModel = ArticlesTableViewCellViewModel(model: model)
        cell.configure(with: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSource.value.count
    }
}

// MARK: - Constants
fileprivate extension ArticlesViewController {
    enum Constants {
        static let progressViewActiveHeightConstraint: CGFloat = 30
        static let progressViewInactiveHeightConstraint: CGFloat = 0
        static let animationDuration: TimeInterval = 0.3
        static let navigationTitle = "Reddit"
    }
}
