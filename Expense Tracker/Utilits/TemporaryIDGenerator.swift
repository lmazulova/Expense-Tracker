import Foundation

final class TemporaryIDGenerator {
    private static let userDefaultsKey = "temporaryTransactionID"
    
    static func generateNextID() -> Int {
        let currentID = UserDefaults.standard.integer(forKey: userDefaultsKey)
        let nextID = currentID - 1 // Используем отрицательные числа для временных ID
        UserDefaults.standard.set(nextID, forKey: userDefaultsKey)
        return nextID
    }
    
    static func isTemporaryID(_ id: Int) -> Bool {
        return id < 0
    }
} 