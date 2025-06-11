import Foundation


struct Transaction: Hashable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}


// MARK: - Конвертирование Transaction в json object и обратно
extension Transaction {
    var jsonObject: Any {
        return [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": NSDecimalNumber(decimal: amount),
            "transactionDate": ISO8601DateFormatter().string(from: transactionDate),
            "comment": comment as Any,
            "createdAt": ISO8601DateFormatter().string(from: createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String : Any],
              let id = dict["id"] as? Int,
              let accountId = dict["accountId"] as? Int,
              let categoryId = dict["categoryId"] as? Int,
              let amountNumber =  dict["amount"] as? NSNumber,
              let transactionDateStr = dict["transactionDate"] as? String,
              let transactionDate = ISO8601DateFormatter().date(from: transactionDateStr),
              let createdAtStr = dict["createdAt"] as? String,
              let createdAt = ISO8601DateFormatter().date(from: createdAtStr),
              let updatedAtStr = dict["updatedAt"] as? String,
              let updatedAt = ISO8601DateFormatter().date(from: updatedAtStr)
        else {
            print("[\(Self.self).parse] — Ошибка десериализации JSON.")
            return nil
        }
        
        let comment = dict["comment"] as? String
        let amount = amountNumber.decimalValue
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
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
    
    var csvLine: String {
        let fields: [String] = [
            String(id),
            String(accountId),
            String(categoryId),
            NSDecimalNumber(decimal: amount).stringValue,
            ISO8601DateFormatter().string(from: transactionDate),
            "\"\(comment ?? "")\"",
            ISO8601DateFormatter().string(from: createdAt),
            ISO8601DateFormatter().string(from: updatedAt)
        ]
        return fields.joined(separator: ",")
    }
    
//  в случае если csv ответ содержит названия полей, перед вызовом функции их нужно удалить
    static func parse(csvLine: String) -> Transaction? {
        let components = csvLine.components(separatedBy: ",")
        
        guard components.count >= 8,
              let id = Int(components[0]),
              let accountId = Int(components[1]),
              let categoryId = Int(components[2]),
              let amount = Decimal(string: components[3]),
              let transactionDate = ISO8601DateFormatter().date(from: components[4]),
              let createdAt = ISO8601DateFormatter().date(from: components[6]),
              let updatedAt = ISO8601DateFormatter().date(from: components[7])
        else {
            print("[\(Self.self).parse] — Ошибка десериализации CSV.")
            return nil
        }
        
        let comment = components[5].isEmpty ? nil : components[5]
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
