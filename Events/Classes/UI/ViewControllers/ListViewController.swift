//
//  ListViewController.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

typealias EventsListViewable = ActivityIndicatorPresentable & ListViewable & AlertPresentable

protocol ListViewable: AnyObject {
    func reloadUI()
    func reloadTable(indexPathes: [IndexPath], isRemoving: Bool)
    func didFinishRefreshDataSource()
    func openBrowser(url: URL)
}

final class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    private var viewModel: ListViewModeling
    
    init(viewModel: ListViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: ListViewController.className, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .japaneseLaurel
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUI()
    }
    
    private func setupViewModel() {
        viewModel.view = self
        viewModel.refreshDataSource(force: false)
    }
    
    private func setupUI() {
        noDataLabel.text = viewModel.noDataText
        noDataLabel.accessibilityIdentifier = EventsAccessibility.eventsListNoDataLabel
        setupTable()
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(EventCell.self)
        if viewModel.needShowRefreshControl {
            tableView.addSubview(refreshControl)
        }
    }

    @objc func refreshTable(_ sender: UIRefreshControl) {
        viewModel.refreshDataSource(force: true)
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.processCellAction(for: indexPath)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.reusableIdentifier,
                                                 for: indexPath)
        (cell as? ConfigurableCell)?.configure(with: cellViewModel)
        (cell as? AccessoryViewActionCell)?.action = { [weak self] in
            self?.viewModel.processAccessoryViewButtonAction(for: indexPath)
        }
        return cell
    }
}

extension ListViewController: EventsListViewable {
    func reloadUI() {
        DispatchQueue.main.async {
            self.noDataLabel.isHidden = !self.viewModel.rows.isEmpty
            self.tableView.reloadData()
        }
    }
    
    func didFinishRefreshDataSource() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    func openBrowser(url: URL) {
        open(url: url)
    }
    
    func reloadTable(indexPathes: [IndexPath], isRemoving: Bool) {
        ///this check is needed, because this vc is used for two view controllers: events anf favorites and we have tabbar application
        ///it means if we still haven't opened favorite vc, view isn't initialized we shouldn't update ui there
        if tableView.window == nil { return }
        
        self.tableView.performBatchUpdates {
            if isRemoving {
                self.tableView.deleteRows(at: indexPathes, with: .fade)
            }
            else {
                self.tableView.reloadRows(at: indexPathes, with: .automatic)
            }
        } completion: { (_) in
            self.noDataLabel.isHidden = !self.viewModel.rows.isEmpty
            self.tableView.reloadData()
        }
    }
}

