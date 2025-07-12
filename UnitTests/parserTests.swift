import XCTest
@testable import Expense_Tracker

// MARK: Задание с двумя звездочками **

final class Expense_TrackerTests: XCTestCase {
    // MARK: Парсинг json
    func testTransactionToJsonAndBack() {
        let original = Transaction(
            id: 1,
            account: BankAccountShort(
                id: 1,
                name: "Основной счет",
                balance: Decimal(string: "1000.00")!,
                currency: .rub
            ),
            category: Category(
                id: 1,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "1234.56")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            comment: "Обед с командой",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        )
        
        let json = original.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.id, original.id)
        XCTAssertEqual(parsed?.account.id, original.account.id)
        XCTAssertEqual(parsed?.account.balance, original.account.balance)
        XCTAssertEqual(parsed?.account.currency, original.account.currency)
        XCTAssertEqual(parsed?.account.name, original.account.name)
        XCTAssertEqual(parsed?.category.id, original.category.id)
        XCTAssertEqual(parsed?.category.emoji, original.category.emoji)
        XCTAssertEqual(parsed?.category.name, original.category.name)
        XCTAssertEqual(parsed?.category.direction, original.category.direction)
        XCTAssertEqual(parsed?.amount, original.amount)
        XCTAssertEqual(parsed?.transactionDate, original.transactionDate)
        XCTAssertEqual(parsed?.comment, original.comment)
        XCTAssertEqual(parsed?.createdAt, original.createdAt)
        XCTAssertEqual(parsed?.updatedAt, original.updatedAt)
    }
    
    func testParseInvalidJson() {
        let invalidJsonObject: [String: Any] = [
            "account": [
                "id": 1,
                "name": "Основной счет",
                "balance": "1000.00",
                "currency": "RUB"
            ],
            "category": [
                "id": 1,
                "name": "Зарплата",
                "emoji": "💰",
                "isIncome": true
            ],
            "amount": NSNumber(value: 1200.0),
            "transactionDate": "2025-06-10T12:00:00Z",
            "createdAt": "2025-06-10T12:05:00Z",
            "updatedAt": "2025-06-10T12:10:00Z"
        ]
        
        let parsed = Transaction.parse(jsonObject: invalidJsonObject)
        
        XCTAssertNil(parsed)
    }
    
    func testTransactionWithNilComment() {
        let transaction = Transaction(
            id: 1,
            account: BankAccountShort(
                id: 1,
                name: "Основной счет",
                balance: 1000.00,
                currency: .rub
            ),
            category: Category(
                id: 1,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "1234.56")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            comment: nil,
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        )
        
        let json = transaction.jsonObject
        let parsed = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.comment, nil)
    }
    
    // MARK: Парсинг csv
    func testTransactionToCsvAndBack() {
        let original = Transaction(
            id: 1,
            account: BankAccountShort(
                id: 1,
                name: "Основной счет",
                balance: Decimal(string: "1000.00")!,
                currency: .rub
            ),
            category: Category(
                id: 1,
                name: "Зарплата",
                emoji: "💰",
                direction: .income
            ),
            amount: Decimal(string: "1234.56")!,
            transactionDate: ISO8601DateFormatter().date(from: "2025-06-10T12:00:00Z")!,
            comment: "Обед с командой",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-10T12:05:00Z")!,
            updatedAt: ISO8601DateFormatter().date(from: "2025-06-10T12:10:00Z")!
        )
        
        let csv = original.csvLine
        let parsed = Transaction.parse(csvLine: csv)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.id, original.id)
        XCTAssertEqual(parsed?.account.id, original.account.id)
        XCTAssertEqual(parsed?.account.balance, original.account.balance)
        XCTAssertEqual(parsed?.account.currency, original.account.currency)
        XCTAssertEqual(parsed?.account.name, original.account.name)
        XCTAssertEqual(parsed?.category.id, original.category.id)
        XCTAssertEqual(parsed?.category.emoji, original.category.emoji)
        XCTAssertEqual(parsed?.category.name, original.category.name)
        XCTAssertEqual(parsed?.category.direction, original.category.direction)
        XCTAssertEqual(parsed?.amount, original.amount)
        XCTAssertEqual(parsed?.transactionDate, original.transactionDate)
        XCTAssertEqual(parsed?.comment, original.comment)
        XCTAssertEqual(parsed?.createdAt, original.createdAt)
        XCTAssertEqual(parsed?.updatedAt, original.updatedAt)
    }
}
