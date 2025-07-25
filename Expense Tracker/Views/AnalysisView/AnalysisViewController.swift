import UIKit
import SwiftUI
import PieChart

class AnalysisViewController: UIViewController {
    // MARK: - Properties

    private let direction: Direction
    private var viewModel: AnalysisViewModel
    private var sortingOrder: SortingOrder
    private var errorAlert: UIAlertController?
    private var loadingIndicator: UIActivityIndicatorView?
    private let categoriesStorage: CategoriesStorage
    private let transactionsStorage: TransactionStorage
    
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
        table.register(UITableViewCell.self, forCellReuseIdentifier: "pieChartCell")
        table.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        return table
    }()
    
    private lazy var pieChart: PieChartView = {
        let view = PieChartView(
            frame: CGRect(),
            colors: ColorScheme(
                color1: .chartGreen,
                color2: .chartYellow,
                color3: .chartRed,
                color4: .chartPurple,
                color5: .chartBlue,
                color6: .chartGrey
            )
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    // MARK: - Initializer

    init(
        direction: Direction,
        categoriesStorage: CategoriesStorage,
        transactionsStorage: TransactionStorage,
        bankAccountStorage: BankAccountStorage
    ) {
        self.direction = direction
        self.categoriesStorage = categoriesStorage
        self.transactionsStorage = transactionsStorage
        self.viewModel = AnalysisViewModel(
            categoriesService: CategoriesService(localStorage: categoriesStorage),
            direction: direction,
            transactionService: TransactionsService(localStorage: transactionsStorage, bankAccountStorage: bankAccountStorage)
        )
        self.sortingOrder = viewModel.selectedOrder
        super.init(nibName: nil, bundle: nil)
        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
            DispatchQueue.main.async {
                self?.updateUIForState()
            }
        }
        Task {
            await viewModel.loadCategories()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    private func updateUIForState() {
        switch viewModel.state {
        case .loading:
            if loadingIndicator == nil {
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.center = view.center
                indicator.startAnimating()
                view.addSubview(indicator)
                loadingIndicator = indicator
            }
        case .error(let message):
            if errorAlert == nil {
                let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .cancel) { [weak self] _ in
                    self?.viewModel.state = .data
                    self?.errorAlert = nil
                    self?.updateUIForState()
                })
                present(alert, animated: true)
                errorAlert = alert
            }
        case .data:
            removeLoadingIndicator()
            tableView.reloadData()
            var entities: [Entity] = []
            for category in viewModel.sortedCategories {
                entities.append(Entity(value: viewModel.sumOfCategory(with: category.id), label: category.name))
            }
            pieChart.entities = entities
        }
    }
    
    private func removeLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
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
        Task {
            await viewModel.loadCategories()
        }
    }
    
    @objc private func handleToDateChange(_ newDate: Date) {
        if newDate < viewModel.startDate {
            viewModel.startDate = newDate
            viewModel.endDate = newDate
            fromDatePicker.date = newDate
        } else {
            viewModel.endDate = newDate
        }
        Task {
            await viewModel.loadCategories()
        }
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
    
    private func setupPieChart(_ cell: UITableViewCell) {
        cell.contentView.addSubview(pieChart)
        
        NSLayoutConstraint.activate([
            pieChart.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            pieChart.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            pieChart.heightAnchor.constraint(equalToConstant: 150),
            pieChart.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupAmount(_ cell: UITableViewCell) {
        cell.textLabel?.text = "Сумма"
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black

        sumLabel.text = "\(viewModel.sumOfTransactions) \(viewModel.currency.rawValue)"

        cell.contentView.addSubview(sumLabel)
        NSLayoutConstraint.activate([
            sumLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            sumLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
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
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            4
        case 1:
            1
        case 2:
            max(0, viewModel.sortedCategories.count)
        default:
            0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? 165 : 60
    }

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
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pieChartCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            setupPieChart(cell)
            return cell
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
        section == 2 ? "Операции" : nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 2 ? 23 : 0
    }
}

//#Preview {
//    AnalysisViewController(direction: .outcome)
//}

