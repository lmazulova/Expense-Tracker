//
//  TransactionRow.swift
//  Expense Tracker
//
//  Created by user on 18.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    private let transaction: Transaction
    private let iconSize: Double = 22
    
    init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    var body: some View {
        HStack {
            Text(String(transaction.category.emoji))
                .font(.system(size: 14.5))
                .frame(width: iconSize, height: iconSize)
                .background(Color.mintGreen)
                .clipShape(.circle)
            
            Text(transaction.category.name)
                .font(.system(size: 17))
            
            Spacer()
            
            Text("\(transaction.amount) \(transaction.account.currency.rawValue)")
                .font(.system(size: 17))
        }
    }
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

