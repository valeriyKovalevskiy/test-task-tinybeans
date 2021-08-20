//
//  ViewController.swift
//  DeveloperChallenge
//
//  Created by Rogerio de Paula Assis on 30/6/17.
//  Copyright © 2017 Tinybeans. All rights reserved.
//

import UIKit
import RxSwift

final class ArticlesViewController: UIViewController {
    private let disposeBag = DisposeBag()

    var viewModel = ArticlesViewModel()
    
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
        viewModel.reddits
            .subscribe(onNext: { [weak self] _ in
                guard let _self = self else { return }
                
                _self.hideDownloadProgressViewWithAnimation()
                _self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingState
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let _self = self else { return }
                
                switch $0 {

                case .loading:
                    _self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                        target: self,
                                                                        action: #selector(_self.cancelDownload))
                    
                case .ready:
                    _self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                                        target: self,
                                                                        action: #selector(_self.refreshData))

                default:
                    break
                }
                debugPrint($0)
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
        viewModel.progress
            .bind(to: downloadProgressViewModel.progress)
            .disposed(by: disposeBag)
        
        downloadProgressView.configure(with: downloadProgressViewModel)
        hideDownloadProgressViewWithAnimation()
    }

    private func setupNavigationItems() {
        navigationItem.title = Constants.navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
    }

    @objc
    private func cancelDownload() {
        hideDownloadProgressViewWithAnimation()
        viewModel.cancelDownload()
    }
    
    @objc
    private func refreshData() {
        showDownloadProgressViewWithAnimation()
        viewModel.downloadData()
    }
    
    private func showDownloadProgressViewWithAnimation() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.downloadProgressViewHeightConstraint.constant = 30
            self?.view.layoutIfNeeded()
        }
    }
    
    private func hideDownloadProgressViewWithAnimation() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.downloadProgressViewHeightConstraint.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - TableView delegate methods
extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ArticlesTableViewCell.self, for: indexPath)
        let model = viewModel.reddits.value[indexPath.row]
        let viewModel = ArticlesTableViewCellViewModel(model: model)
        cell.configure(with: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reddits.value.count
    }
}

// MARK: - Constants
fileprivate extension ArticlesViewController {
    enum Constants {
        static let navigationTitle = "Reddit"
    }
}
