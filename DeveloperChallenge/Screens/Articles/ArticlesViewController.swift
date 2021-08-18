//
//  ViewController.swift
//  DeveloperChallenge
//
//  Created by Rogerio de Paula Assis on 30/6/17.
//  Copyright © 2017 Tinybeans. All rights reserved.
//

import UIKit

final class ArticlesViewController: UIViewController {
    
    var viewModel = ArticlesViewModel()
    
    // MARK: - Outlets
    @IBOutlet private var tableView: UITableView!
    
    let progressView = UIProgressView(progressViewStyle: .bar)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchData()
        setupTableView()
        setupNavigationItems()
        setupProgressView()
    }
    
    // MARK: - Private
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(class: ArticlesTableViewCell.self)
    }
    
    private func setupNavigationItems() {
        navigationItem.title = "Reddit"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
    }
    
    private func setupProgressView() {
        progressView.backgroundColor = UIColor.gray
    }
    
    @objc
    private func refreshData() {
        self.progressView.progress = 0
        tableView.tableHeaderView = progressView
        self.progressView.progress = 0.5

        viewModel.fetchReddits { [weak self] success in
            guard let _self = self else { return }
            
            _self.progressView.setProgress(1, animated: true)
            _self.viewModel.fetchData()
            _self.tableView.reloadData()
            _self.tableView.tableHeaderView = nil
        }
    }
}

// MARK: - TableView delegate methods
extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ArticlesTableViewCell.self, for: indexPath)
        cell.textLabel?.text = viewModel.reddits[indexPath.row].message
        cell.detailTextLabel?.text = viewModel.reddits[indexPath.row].author
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.reddits.count
    }
}
