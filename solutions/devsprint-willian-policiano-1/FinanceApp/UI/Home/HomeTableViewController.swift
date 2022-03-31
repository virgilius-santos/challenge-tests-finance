//
//  HomeTableViewController.swift
//  FinanceApp
//
//  Created by Willian Policiano on 22/03/22.
//

import UIKit

protocol HomeFetcher {
    func getHome(completion: @escaping (Result<HomeViewModel, HomeErrorViewModel>) -> Void)
}

class HomeTableViewController: UITableViewController {
    private let service: HomeFetcher
    private var home: HomeViewModel = HomeViewModel(rows: []) {
        didSet {
            tableView.reloadData()
        }
    }

    init(service: HomeFetcher) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(getHome), for: .valueChanged)

        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getHome()
    }

    @objc
    func getHome() {
        refreshControl?.beginRefreshing()

        service.getHome { [weak self] result in
            self?.refreshControl?.endRefreshing()

            switch result {
            case let .success(home):
                self?.home = home
            case let .failure(error):
                self?.presentError(error)
            }
        }
    }

    private func presentError(_ error: HomeErrorViewModel) {
        let alert = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: error.cancelActionTitle, style: .destructive))
        alert.addAction(UIAlertAction(title: error.primaryActionTitle, style: .default, handler: { [weak self] _ in
            self?.getHome()
        }))

        showDetailViewController(alert, sender: self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        home.rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = home.rows[indexPath.row]

        switch item {
        case let .untitled(value):
            let cell = BalanceCell()
            cell.display(value: value)
            return cell
        case let .titled(title, value):
            let cell = FinanceCell()
            cell.display(title: title, value: value)
            return cell
        }
    }
}
