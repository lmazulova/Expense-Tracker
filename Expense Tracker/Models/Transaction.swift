import Foundation
import os.log

struct Transaction: Hashable, Identifiable {
    let id: Int
    let account: BankAccountShort
    let category: Category
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}


// MARK: - Конвертирование Transaction в json object и обратно
extension Transaction {
    
    private static let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "TransactionParser"
    )
    
    var jsonObject: Any {
        return [
            "id": id,
            "account": [
                "id": account.id,
                "name": account.name,
                "balance": NSDecimalNumber(decimal: account.balance).stringValue,
                "currency": account.currency
            ],
            "category": [
                "id": category.id,
                "name": category.name,
                "emoji": String(category.emoji),
                "isIncome": category.direction == .income ? true : false
            ],
            "amount": NSDecimalNumber(decimal: amount).stringValue,
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment as Any,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String : Any],
              let id = dict["id"] as? Int,
              let accountDict = dict["account"] as? [String : Any],
              let accountId = accountDict["id"] as? Int,
              let accountName = accountDict["name"] as? String,
              let accountBalanceStr = accountDict["balance"] as? String,
              let accountBalance = Decimal(string: accountBalanceStr),
              let accountCurrencyStr = accountDict["currency"] as? String,
              let categoryDict = dict["category"] as? [String : Any],
              let categoryId = categoryDict["id"] as? Int,
              let categoryName = categoryDict["name"] as? String,
              let categoryEmojiStr = categoryDict["emoji"] as? String,
              let categoryEmoji = categoryEmojiStr.first,
              let categoryIsIncome = categoryDict["isIncome"] as? Bool,
              let amountStr =  dict["amount"] as? String,
              let amount = Decimal(string: amountStr),
              let transactionDateStr = dict["transactionDate"] as? String,
              let transactionDate = ISO8601DateFormatter().date(from: transactionDateStr),
              let createdAtStr = dict["createdAt"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtStr),
              let updatedAtStr = dict["updatedAt"] as? String,
              let updatedAt = ISO8601DateFormatter().date(from: updatedAtStr)
        else {
            os_log("‼️ Ошибка десериализации JSON",
                   log: Self.log,
                   type: .error)
            return nil
        }
        
        let comment = dict["comment"] as? String
        
        var accountCurrency: Currency {
            switch accountCurrencyStr {
            case "RUB":
                return .rub
            case "USD":
                return .usd
            case "EUR":
                return .eur
            default:
                return .rub
            }
        }
        
        return Transaction(
            id: id,
            account: BankAccountShort(id: accountId, name: accountName, balance: accountBalance, currency: accountCurrency),
            category: Category(id: categoryId, name: categoryName, emoji: categoryEmoji, direction: categoryIsIncome ? .income : .outcome),
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}


// MARK: Задание со звездочкой * - Конвертирование Transaction в csv и обратно
extension Transaction {
    static let csvHeader = [
        "id",
        "account.id",
        "account.name",
        "account.balance",
        "account.currency",
        "category.id",
        "category.name",
        "category.emoji",
        "category.isIncome",
        "amount",
        "transactionDate",
        "comment",
        "createdAt",
        "updatedAt"
    ]
  
    var csvLine: String {
        
        var currency: String {
            switch account.currency {
            case .eur:
                return "EUR"
            case .usd:
                return "USD"
            case .rub:
                return "RUB"
            }
        }
        
        let fields: [String] = [
            String(id),
            String(account.id),
            account.name,
            NSDecimalNumber(decimal: account.balance).stringValue,
            currency,
            String(category.id),
            category.name,
            String(category.emoji),
            category.direction == .income ? "true" : "false",
            NSDecimalNumber(decimal: amount).stringValue,
            ISO8601DateFormatter().string(from: transactionDate),
            comment ?? "",
            ISO8601DateFormatter().string(from: createdAt),
            ISO8601DateFormatter().string(from: updatedAt)
        ]
        return fields.joined(separator: ",")
    }
    
//  в случае если csv ответ содержит названия полей, перед вызовом функции их нужно удалить
    static func parse(csvLine: String) -> Transaction? {
        let components = csvLine.components(separatedBy: ",")
        
        guard components.count >= 14,
              let id = Int(components[0]),
              let accountId = Int(components[1]),
              let accountBalance = Decimal(string: components[3]),
              let categoryId = Int(components[5]),
              let categoryEmoji = components[7].first,
              let isIncome = Bool(components[8]),
              let amount = Decimal(string: components[9]),
              let transactionDate = ISO8601DateFormatter().date(from: components[10]),
              let createdAt = ISO8601DateFormatter().date(from: components[12]),
              let updatedAt = ISO8601DateFormatter().date(from: components[13])
        else {
            os_log("‼️ Ошибка десериализации CSV",
                   log: Self.log,
                   type: .error)
            return nil
        }
        
        let comment = components[11].isEmpty ? nil : components[11]
        
        var accountCurrency: Currency {
            switch components[4] {
            case "RUB":
                return .rub
            case "USD":
                return .usd
            case "EUR":
                return .eur
            default:
                return .rub
            }
        }
        return Transaction(
            id: id,
            account: BankAccountShort(
                id: accountId,
                name: components[2],
                balance: accountBalance,
                currency: accountCurrency
            ),
            category: Category(
                id: categoryId,
                name: components[6],
                emoji: categoryEmoji,
                direction: isIncome ? .income : .outcome
            ),
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
