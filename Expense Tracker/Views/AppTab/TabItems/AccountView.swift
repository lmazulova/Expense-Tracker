//
//  AccountView.swift
//  Expense Tracker
//
//  Created by user on 18.06.2025.
//

import SwiftUI

struct AccountView: View {
    @State var isEditMode: Bool = false
    @State var bankAccount: BankAccountManager
    @State var currency: Currency
    @State var balance: Decimal
    
    init() {
        let manager = BankAccountManager()
        _bankAccount = State(wrappedValue: manager)
        _currency = State(initialValue: manager.account.currency)
        _balance = State(initialValue: manager.account.balance)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            BalanceRow(balance: $balance, currency: $currency)
            CurrencyRow(currency: $currency)
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            if !isEditMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Text("Редактировать")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.violet)
                    }
                }
            }
            else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { }) {
                        Text("Сохранить")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.violet)
                    }
                }
            }
        }
        .onChange(of: currency) { _, newValue in
            bankAccount.updateCurrency(newValue)
        }
        .onChange(of: balance) { _, newValue in
            bankAccount.updateBalance(newValue)
        }
    }
    
    private struct BalanceRow: View {
        let emoji: Character = "💰"
        let text: String = "Баланс"
        @Binding var balance: Decimal
        @Binding var currency: Currency
        
        var body: some View {
            HStack(spacing: 16) {
                Text("💰")
                
                Text("Баланс")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(balance) \(currency.rawValue)")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.accent)
            )
        }
    }
    
    private struct CurrencyRow: View {
        let text: String = "Валюта"
        @Binding var currency: Currency
        var body: some View {
            HStack {
                Text("Валюта")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(currency.rawValue)")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mintGreen)
            )
        }
    }
}
    
#Preview {
//    AccountView()
}

