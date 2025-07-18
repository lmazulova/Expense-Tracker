import UIKit
import SwiftUI

class AnalysisViewController: UIViewController {
    // MARK: - Properties

    private let direction: Direction
//    private let currency: Currency = BankAccountManager().account.currency
    private var viewModel: AnalysisViewModel
    private var sortingOrder: SortingOrder

    // MARK: - Lazy Views

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var sumLabel: UILabel = {
        let label = UILabel()
        label.text = "\(viewModel.sumOfTransactions) \(viewModel.currency.rawValue)"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var fromDatePicker: CustomDatePickerView = {
        let picker = CustomDatePickerView()
        picker.onDateChanged = handleFromDateChange
        return picker
    }()

    private lazy var toDatePicker: CustomDatePickerView = {
        let picker = CustomDatePickerView()
        picker.onDateChanged = handleToDateChange
        return picker
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.separatorStyle = .singleLine
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "startDateCell")
        table.register(UITableViewCell.self, forCellReuseIdentifier: "endDateCell")
        table.register(UITableViewCell.self, forCellReuseIdentifier: "sortCell")
        table.register(UITableViewCell.self, forCellReuseIdentifier: "amountCell")
        table.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        return table
    }()

    // MARK: - Initializer

    init(direction: Direction) {
        self.direction = direction
        self.viewModel = AnalysisViewModel(direction: direction)
        self.sortingOrder = viewModel.selectedOrder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }

    // MARK: - Layout

    private func configureLayout() {
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(titleLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Date Handlers

    @objc private func handleFromDateChange(_ newDate: Date) {
        if newDate > viewModel.endDate {
            viewModel.startDate = newDate
            viewModel.endDate = newDate
            toDatePicker.date = newDate
        } else {
            viewModel.startDate = newDate
        }
        viewModel.sortCategories()
        tableView.reloadData()
    }

    @objc private func handleToDateChange(_ newDate: Date) {
        if newDate < viewModel.startDate {
            viewModel.startDate = newDate
            viewModel.endDate = newDate
            fromDatePicker.date = newDate
        } else {
            viewModel.endDate = newDate
        }
        viewModel.sortCategories()
        tableView.reloadData()
    }

    // MARK: - Cell Configurators

    private func setupDateCell(_ cell: UITableViewCell, title: String, date: Date, selector: Selector) {
        cell.textLabel?.text = title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black

        let picker: CustomDatePickerView
        switch selector {
        case #selector(handleFromDateChange(_:)):
            picker = fromDatePicker
        default:
            picker = toDatePicker
        }
        picker.date = date
        picker.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.layer.cornerRadius = 6
        container.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 34),
        ])
        
        cell.accessoryView = container
        cell.accessoryView?.frame.size = CGSize(width: 140, height: 34)
    }

    private func setupAmount(_ cell: UITableViewCell) {
        cell.textLabel?.text = "Сумма"
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black

        sumLabel.text = "\(viewModel.sumOfTransactions) \(viewModel.currency.rawValue)"

        cell.contentView.addSubview(sumLabel)
        NSLayoutConstraint.activate([
            sumLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            sumLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
    }
    
    private func setupSortCell(_ cell: UITableViewCell) {
        cell.textLabel?.text = "Сортировка"
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black

        // Кнопка для выбора сортировки
        let button = UIButton(type: .system)
        button.setTitle(sortingOrder.rawValue, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.backgroundColor = .mintGreen
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.showsMenuAsPrimaryAction = true
        
        // Создаём меню
        let menu = UIMenu(children: SortingOrder.allCases.map { order in
            UIAction(
                title: order.rawValue,
                state: order == sortingOrder ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }
                self.sortingOrder = order
                button.setTitle(order.rawValue, for: .normal)
                self.viewModel.setFilters(order: order)
                self.viewModel.sortCategories()
                self.tableView.reloadData()
            }
        })
        button.menu = menu

        // Добавляем в accessoryView
        cell.accessoryView = button
        cell.accessoryView?.frame.size = CGSize(width: 150, height: 34)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 4 : max(0, viewModel.sortedCategories.count)
    }

    private func tableView(_ tableView: UITableView, heightForRowInSection section: Int) -> Int { 60 }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemGroupedBackground
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "startDateCell", for: indexPath)
                cell.backgroundColor = .white
                cell.selectionStyle = .none
                setupDateCell(cell, title: "Период: начало", date: viewModel.startDate, selector: #selector(handleFromDateChange))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "endDateCell", for: indexPath)
                cell.backgroundColor = .white
                cell.selectionStyle = .none
                setupDateCell(cell, title: "Период: конец", date: viewModel.endDate, selector: #selector(handleToDateChange))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath)
                cell.backgroundColor = .white
                cell.selectionStyle = .none
                setupSortCell(cell)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "amountCell", for: indexPath)
                cell.backgroundColor = .white
                cell.selectionStyle = .none
                setupAmount(cell)
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as! TransactionCell
            let category = viewModel.sortedCategories[indexPath.row]
            cell.configure(
                with: category,
                amount: viewModel.sumOfTransactions,
                categorySum: viewModel.sumOfCategory(with: category.id),
                currency: viewModel.currency
            )
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "Операции" : nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : 40
    }
}

#Preview {
    AnalysisViewController(direction: .outcome)
}
