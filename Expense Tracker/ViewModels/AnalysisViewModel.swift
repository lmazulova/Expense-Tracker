
import SwiftUI

final class AnalysisViewModel {
    var state: LoadingState = .loading
    var onDataChanged: (() -> Void)?
    var categories: [Category] = []
    var sortedCategories: [Category] = []
    var filteredTransactions: [Transaction] = []
    var sumOfTransactions: Decimal {
        return filteredTransactions
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    var startDate: Date
    var endDate: Date 
    var direction: Direction
    var currency: Currency
    private var transactionsService: TransactionsService
    private(set) var selectedOrder: SortingOrder = .none
    private var categoriesService: CategoriesService
    
    init(
        categoriesService: CategoriesService,
        direction: Direction,
        transactionService: TransactionsService
    ) {
        let initialStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.startDate = Calendar.current.startOfDay(for: initialStartDate)
        self.endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        self.categoriesService = categoriesService
        self.direction = direction
        self.transactionsService = transactionService
        self.currency = transactionService.currency
    }
    
    func loadCategories() async {
        state = .loading
        do {
            await loadTransactions()
            await categories = try categoriesService.categories(with: direction)
            sortCategories()
            state = .data
        } catch {
            print("Ошибка загрузки транзакций")
            state = .error(error.localizedDescription)
        }
        DispatchQueue.main.async { [weak self] in
            self?.onDataChanged?()
        }
    }
    private func loadTransactions() async {
        do {
            filteredTransactions = try await transactionsService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
        }
        catch {
            print(error.localizedDescription)
            filteredTransactions = []
        }
    }
    func setFilters(order: SortingOrder) {
        selectedOrder = order
    }
    
    func sumOfCategory(with id: Int) -> Decimal {
        return filteredTransactions
            .filter { $0.category.id == id }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    func sortCategories() {
        //Применяем фильтрацию по выбранной категории
        let filtered = categories.filter { sumOfCategory(with: $0.id) != 0 }
        switch selectedOrder {
        case .ascending:
            self.sortedCategories = filtered.sorted { sumOfCategory(with: $0.id) < sumOfCategory(with: $1.id) }
        case .descending:
            self.sortedCategories = filtered.sorted { sumOfCategory(with: $0.id) > sumOfCategory(with: $1.id) }
        case .none:
            self.sortedCategories = filtered
        }
    }
}
