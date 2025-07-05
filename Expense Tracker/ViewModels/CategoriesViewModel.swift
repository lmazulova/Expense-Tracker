import SwiftUI
import Foundation
import Combine

@MainActor
@Observable
final class CategoriesViewModel {
    var allCategories: [Category] = [] {
        didSet { filterCategories() }
    }
    var filteredCategories: [Category] = []
    var searchText: String = "" {
        didSet { debounceSearch() }
    }
    private var debounceTask: Task<Void, Never>? = nil
    
    func loadCategories() async {
        do {
            let categories = try await CategoriesService().categories()
            self.allCategories = categories
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }
    
    private func filterCategories() {
        if searchText.isEmpty {
            filteredCategories = allCategories
        } else {
            self.filteredCategories = allCategories.filter { category in
                let contains = category.name.lowercased().contains(searchText.lowercased())
                //Немного усложненная логика, суть в том чтобы при короткой длине введенного текста для попадания в выборку должно быть мало опечаток.
                let isMisprint = levenshteinDistance(category.name.lowercased(), searchText.lowercased()) <= min(max(searchText.count - 2, 0), 3)
                return contains || isMisprint
            }
        }
    }
    
    //Чтобы избежать частых вызовов фильтрации при вводе текста, используем дебаунс.
    private func debounceSearch() {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                filterCategories()
            }
        }
    }
}

//MARK: - Filtration metric
//В качестве метрики "похожести" строк будем использовать расстояние Левенштейна.
extension CategoriesViewModel {
    func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
        //Для оптимизации по памяти выберем самую короткую строку
        let (shorter, longer) = lhs.count < rhs.count ? (lhs, rhs) : (rhs, lhs)
        var dp = [Array(0...shorter.count), Array(0...shorter.count)]
        
        var shorterIndex = shorter.startIndex
        var longerIndex = longer.startIndex
        
        for j in 1...longer.count {
            dp[0][0] = j - 1
            dp[1][0] = j
            for i in 1...shorter.count {
                let temp = dp[1][i]
                dp[1][i] = min(
                    dp[1][i - 1] + 1,
                    dp[1][i] + 1,
                    dp[0][i - 1] + (shorter[shorterIndex] == longer[longerIndex] ? 0 : 1)
                )
                dp[0][i] = temp
                shorterIndex = shorter.index(after: shorterIndex)
            }
            shorterIndex = shorter.startIndex
            longerIndex = longer.index(after: longerIndex)
        }
        return dp[1][shorter.count]
    }
}
