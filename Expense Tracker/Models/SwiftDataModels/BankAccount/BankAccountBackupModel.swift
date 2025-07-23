import Foundation
import SwiftData

@Model
final class BankAccountBackupModel {
    var balance: Decimal
    var currencyRaw: String
    var timestamp: Date = Date()
    
    init(balance: Decimal, currencyRaw: String) {
        self.balance = balance
        self.currencyRaw = currencyRaw
    }
}
