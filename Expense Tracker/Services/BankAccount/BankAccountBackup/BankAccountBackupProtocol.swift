import Foundation

protocol BankAccountBackupProtocol {
    func saveBackupUpdate(balance: Decimal, currency: Currency) async throws
    func fetchBackupUpdate() async throws -> BankAccountBackupModel?
    func clearBackupUpdates() async throws
}
