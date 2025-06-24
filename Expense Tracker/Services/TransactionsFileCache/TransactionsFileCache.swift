import Foundation
import OSLog

final class TransactionsFileCache {
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "TransactionsFileCache"
    )
//  Кажется нам не важен порядок, в котором хранятся транзакции,  любом случае их можно будет отфильтровать по дате, поэтому здесь использую сет, чтобы быстро искать дубликаты
    private(set) var transactions: Set<Transaction> = [
        Transaction(
            id: 1,
            account: BankAccountShort(id: 100, name: "Основной счет", balance: 1000.00, currency: .rub),
            category: Category( id: 1, name: "Зарплата", emoji: "💰", direction: .income),
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
            os_log("‼️ Невалидный JSON", log: log, type: .error)
            return
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
            try data.write(to: URL(fileURLWithPath: path))
        }
        catch {
            os_log("‼️ Ошибка при сохранении: %{public}@", log: log, type: .error, error.localizedDescription)
        }
    }
    
    func load(from path: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            guard let array = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                os_log("‼️ Невалидный JSON", log: log, type: .error)
                return
            }
            let loadedData = array.compactMap { Transaction.parse(jsonObject: $0) }
            self.transactions = Set(loadedData)
        }
        catch {
            os_log("‼️ Ошибка записи из файла: %{public}@", log: log, type: .error, error.localizedDescription)
        }
    }
}
