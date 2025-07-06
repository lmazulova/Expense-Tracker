//
//  TransactionRow.swift
//  Expense Tracker
//
//  Created by user on 18.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    private let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var body: some View {
        HStack {
            Text(String(transaction.category.emoji))
                .font(.system(size: 14.5))
                .frame(width: ViewConstants.iconSize, height: ViewConstants.iconSize)
                .background(Color.mintGreen)
                .clipShape(.circle)
            
            Text(transaction.category.name)
                .font(.system(size: 17))
            
            Spacer()
            
            Text("\(transaction.amount) \(transaction.account.currency.rawValue)")
                .font(.system(size: 17))
                .padding(.trailing, 16)
        }
        .frame(idealHeight: ViewConstants.idealHeight, maxHeight: ViewConstants.maxHeight)
    }
}

private enum ViewConstants {
    static let iconSize: Double = 22
    static let idealHeight: Double = 44
    static let maxHeight: Double = 64
}
#Preview {
    TransactionRowView(transaction: Transaction(
        id: 4,
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
        amount: Decimal(string: "75.50")!,
        transactionDate: ISO8601DateFormatter().date(from: "2025-06-07T08:15:00Z")!,
        comment: "Такси до офиса",
        createdAt: ISO8601DateFormatter().date(from: "2025-06-07T08:16:00Z")!,
        updatedAt: ISO8601DateFormatter().date(from: "2025-06-07T08:17:00Z")!
    ))
}

