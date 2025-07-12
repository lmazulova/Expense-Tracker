//
//  AnalysisView.swift
//  Expense Tracker
//
//  Created by user on 10.07.2025.
//

//import UIKit
//
//final class AnalysisViewController: UIViewController {
//    private var viewModel: AnalysisViewModel
//    
//    init(viewModel: AnalysisViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private lazy var headerTableView: UITableView = {
//        let tableView = UITableView()
//        tableView.backgroundColor = .white
//        tableView.layer.cornerRadius = 11
//        tableView.isScrollEnabled = true
//        tableView.rowHeight = 44
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        tableView.register(PeriodCell.self, forCellReuseIdentifier: PeriodCell.identifier)
//        tableView.register(AmountCell.self, forCellReuseIdentifier: AmountCell.identifier)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorColor = UIColor(named: "textGray")
//        tableView.allowsMultipleSelection = false
//        
//        return tableView
//    }()
//    
//    private lazy var transactionTableView: UITableView = {
//        let tableView = UITableView()
//        tableView.backgroundColor = .white
//        tableView.layer.cornerRadius = 11
//        tableView.isScrollEnabled = true
//        tableView.rowHeight = 60
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.separatorColor = UIColor(named: "textGray")
//        tableView.allowsMultipleSelection = false
//        
//        return tableView
//    }()
//    
//    override func viewDidLoad() {
//        
//    }
//    
//    func setupConstraints() {
//        
//    }
//}
//
//extension AnalysisViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if tableView == transactionTableView {
//            let label = UILabel()
//            label.text = "ОПЕРАЦИИ"
//            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//            label.textColor = .systemGray
//            label.textAlignment = .left
//            label.backgroundColor = .clear
//            label.translatesAutoresizingMaskIntoConstraints = false
//            
//            let container = UIView()
//            container.backgroundColor = .clear
//            container.addSubview(label)
//            NSLayoutConstraint.activate([
//                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
//                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
//                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
//                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
//            ])
//            return container
//        } else {
//            return nil
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if tableView == transactionTableView {
//            return 16
//        } else {
//            return 0
//        }
//    }
//}
//
//extension AnalysisViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        viewModel.sortedCategories.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    
//    }
//}
