import Foundation

@Observable
final class TransactionsService {
    static let shared: TransactionsService = TransactionsService()
    
    private init() {
    }
    
    private(set) var allTransactions: Set<Transaction> = [
        Transaction(
            id: 1,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 1000.00,
                currency: .rub
            ),
            category: Category(
                id: 2,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "1234.56")!,
            transactionDate: Date(),
            comment: "Обед с командой",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        ),
        Transaction(
            id: 140,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 1300.50,
                currency: .rub
            ),
            category: Category(
                id: 5,
                name: "Подработка",
                emoji: "💵",
                direction: .income
            ),
            amount: Decimal(string: "1234.56")!,
            transactionDate: Date(),
            comment: "Обед с командой",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        ),
        Transaction(
            id: 2,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 1000.00,
                currency: .rub
            ),
            category: Category(
                id: 2,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "4999.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            comment: "Зарплата за май",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-09T09:31:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-09T09:32:00Z")!
        ),
        Transaction(
            id: 3,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 1000.00,
                currency: .rub
            ),
            category: Category(
                id: 2,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "199.99")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            comment: "Покупка игры в Steam",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-08T18:46:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-08T18:46:00Z")!
        ),
        Transaction(
            id: 4,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 1000.00,
                currency: .rub
            ),
            category: Category(
                id: 2,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "75.50")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            comment: "Такси до офиса",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-07T08:16:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-07T08:17:00Z")!
        ),
        Transaction(
            id: 5,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 1000.00,
                currency: .rub
            ),
            category: Category(
                id: 7,
                name: "Кэшбек",
                emoji: "💸",
                direction: .income
            ),
            amount: Decimal(string: "250.00")!,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 6,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 800.00,
                currency: .rub
            ),
            category: Category(
                id: 8,
                name: "Продукты",
                emoji: "🛒",
                direction: .outcome
            ),
            amount: Decimal(string: "-350.75")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            comment: "Покупка продуктов в супермаркете",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-06T15:20:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-06T15:21:00Z")!
        ),
        Transaction(
            id: 7,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 600.00,
                currency: .rub
            ),
            category: Category(
                id: 1,
                name: "Еда",
                emoji: "🍔",
                direction: .outcome
            ),
            amount: Decimal(string: "-120.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            comment: "Кофе с друзьями",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-07T10:00:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-07T10:01:00Z")!
        ),
        Transaction(
            id: 8,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 500.00,
                currency: .rub
            ),
            category: Category(
                id: 3,
                name: "Транспорт",
                emoji: "🚌",
                direction: .outcome
            ),
            amount: Decimal(string: "-50.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            comment: "Метро",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-03T08:30:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-03T08:31:00Z")!
        ),
        Transaction(
            id: 9,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 450.00,
                currency: .rub
            ),
            category: Category(
                id: 4,
                name: "Медицина ",
                emoji: "💊",
                direction: .outcome
            ),
            amount: Decimal(string: "-200.00")!,
            transactionDate: Date(),
            comment: "Покупка лекарств",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 10,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 400.00,
                currency: .rub
            ),
            category: Category(
                id: 6,
                name: "Развлечения",
                emoji: "💃",
                direction: .outcome
            ),
            amount: Decimal(string: "-150.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            comment: "Кино",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-04T20:00:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-04T20:01:00Z")!
        ),
        Transaction(
            id: 11,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 300.00,
                currency: .rub
            ),
            category: Category(
                id: 9,
                name: "Дом",
                emoji: "🏠",
                direction: .outcome
            ),
            amount: Decimal(string: "-100.00")!,
            transactionDate: Date(),
            comment: "Покупка бытовой химии",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 12,
            account: BankAccount(
                id: 1,
                name: "Основной счет",
                balance: 250.00,
                currency: .rub
            ),
            category: Category(
                id: 10,
                name: "Подарки",
                emoji: "🎁",
                direction: .outcome
            ),
            amount: Decimal(string: "-50.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            comment: "Подарок другу",
            createdAt: ISO8601DateFormatter().date(from: "2025-05-30T18:00:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-05-30T18:01:00Z")!
        ),
        Transaction(
            id: 13,
            account: BankAccount(id: 100, name: "Основной счет", balance: 200.00, currency: .rub),
            category: Category(
                id: 9,
                name: "Дом",
                emoji: "🏠",
                direction: .outcome
            ),
            amount: Decimal(string: "-80.00")!,
            transactionDate: Date(), // today
            comment: "Покупка книги",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 14,
            account: BankAccount(id: 100, name: "Основной счет", balance: 120.00, currency: .rub),
            category: Category(
                id: 3,
                name: "Транспорт",
                emoji: "🚌",
                direction: .outcome
            ),
            amount: Decimal(string: "-150.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            comment: "Поездка на такси",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 15,
            account: BankAccount(id: 100, name: "Основной счет", balance: 70.00, currency: .rub),
            category: Category(
                id: 10,
                name: "Подарки",
                emoji: "🎁",
                direction: .outcome
            ),
            amount: Decimal(string: "-300.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            comment: "Покупка футболки",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 16,
            account: BankAccount(id: 100, name: "Основной счет", balance: 50.00, currency: .rub),
            category: Category(
                id: 10,
                name: "Подарки",
                emoji: "🎁",
                direction: .outcome
            ),
            amount: Decimal(string: "-60.00")!,
            transactionDate: Date(),
            comment: "Крем для лица",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 17,
            account: BankAccount(id: 100, name: "Основной счет", balance: 30.00, currency: .rub),
            category: Category(
                id: 11,
                name: "Связь",
                emoji: "📱",
                direction: .outcome
            ),
            amount: Decimal(string: "-20.00")!,
            transactionDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            comment: "Оплата мобильной связи",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        allTransactions.filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        guard !allTransactions.contains(where: { $0.id == transaction.id }) else { return }
        allTransactions.insert(transaction)
    }
    
    func editTransaction(_ editedTransaction: Transaction) async throws {
        guard let transaction = allTransactions.first(where: { $0.id == editedTransaction.id }) else { return }
        allTransactions.remove(transaction)
        allTransactions.insert(editedTransaction)
    }
    
    func deleteTransaction(byId id: Int) async throws {
        guard let transaction = allTransactions.first(where: { $0.id == id }) else { return }
        allTransactions.remove(transaction)
    }
}
