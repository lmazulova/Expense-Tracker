import XCTest
@testable import Expense_Tracker

//MARK: Задание с двумя звездочками **

final class Expense_TrackerTests: XCTestCase {
    
    func testTransactionToJsonAndBack() {
        let original = Transaction(
            id: 1,
            accountId: 100,
            categoryId: 5,
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
        XCTAssertEqual(parsed?.accountId, original.accountId)
        XCTAssertEqual(parsed?.categoryId, original.categoryId)
        XCTAssertEqual(parsed?.amount, original.amount)
        XCTAssertEqual(parsed?.transactionDate, original.transactionDate)
        XCTAssertEqual(parsed?.comment, original.comment)
        XCTAssertEqual(parsed?.createdAt, original.createdAt)
        XCTAssertEqual(parsed?.updatedAt, original.updatedAt)
    }
    
    func testParseInvalidJson() {
        let invalidJsonObject: [String: Any] = [
            "accountId": 100,
            "categoryId": 5,
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
            accountId: 100,
            categoryId: 5,
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
}
