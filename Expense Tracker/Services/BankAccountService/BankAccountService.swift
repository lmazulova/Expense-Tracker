import Foundation

actor BankAccountService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    func currentAccount() async throws -> BankAccount {
        let accounts = try await networkClient.send(GetAccountRequest())
        guard let account = accounts.first else {
            throw NSError(domain: "NoAccounts", code: 0, userInfo: nil)
        }
        return account
    }
    
    func updateAccount(_ updated: BankAccount) async throws -> BankAccount {
        try await networkClient.send(UpdateAccountRequest(account: updated))
    }
}
