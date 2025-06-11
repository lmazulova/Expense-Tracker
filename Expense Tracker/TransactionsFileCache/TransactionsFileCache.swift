import Foundation

final class TransactionsFileCache {
    
//  Кажется сейчас нам не важен порядок, в котором хранятся транзакции,  любом случае их можно будет отфильтровать по дате, поэтому здесь использую сет, чтобы быстро искать дубликаты
    private(set) var transactions: Set<Transaction> = [
        Transaction(
            id: 1,
            accountId: 100,
            categoryId: 5,
            amount: Decimal(string: "1234.56")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            comment: "Обед с командой",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        )
    ]
    
    func addNewTransaction(_ transaction: Transaction) {
        if !transactions.contains(transaction) {
            transactions.insert(transaction)
        }
    }
    
    func deleteTransaction(byId id: Int) {
        if let transaction = transactions.first(where: { $0.id == id }) {
            transactions.remove(transaction)
        }
    }
    
    func save(to path: String) {
        let jsonArray = transactions.map { $0.jsonObject }
        
        guard JSONSerialization.isValidJSONObject(jsonArray) else {
            print("[\(#function)] - невалидный JSON")
            return
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
            try data.write(to: URL(fileURLWithPath: path))
        }
        catch {
            print("[\(#function)] - Ошибка при сохранении: \(error)")
        }
    }
    
    func load(from path: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            guard let array = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                print("[\(#function)] - невалидный JSON")
                return
            }
            let loadedData = array.compactMap { Transaction.parse(jsonObject: $0) }
            self.transactions = Set(loadedData)
        }
        catch {
            print("[\(#function)] - Ошибка записи из файла: \(error)")
        }
    }
}
