
import SwiftUI

final class AnalysisViewModel {
    var categories: [Category] = []
    var sortedCategories: [Category] = []
    var sumOfTransactions: Decimal {
        return TransactionsService.shared.allTransactions
            .filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
            .filter { $0.category.direction == direction}
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    var startDate: Date
    var endDate: Date 
    var direction: Direction
    private(set) var selectedOrder: SortingOrder = .none
    private var categoriesService: CategoriesService
    
    init(categoriesService: CategoriesService = CategoriesService(), direction: Direction) {
        let initialStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        self.startDate = Calendar.current.startOfDay(for: initialStartDate)
        self.endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        self.categoriesService = categoriesService
        self.direction = direction
        Task {
            await loadCategories()
        }
    }
    
    func loadCategories() async {
        Task {
            do {
                await categories = try categoriesService.categories(with: direction)
                sortCategories()
            } catch {
                
            }
        }
    }
    
    func setFilters(order: SortingOrder) {
        selectedOrder = order
    }
    
    func sumOfCategory(with id: Int) -> Decimal {
        return TransactionsService.shared.allTransactions
            .filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
            .filter { $0.category.direction == direction && $0.category.id == id }
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
