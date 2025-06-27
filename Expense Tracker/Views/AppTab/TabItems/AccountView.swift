//
//  AccountView.swift
//  Expense Tracker
//
//  Created by user on 18.06.2025.
//

import SwiftUI

extension Decimal {
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }
}

struct AccountView: View {
    @State var isEditMode: Bool = false
    @State var bankAccount: BankAccountManager
    @State var currency: Currency
    @State var balance: Decimal
    @State var showPopup: Bool = false
    
    init() {
        let manager = BankAccountManager()
        _bankAccount = State(wrappedValue: manager)
        _currency = State(initialValue: manager.account.currency)
        _balance = State(initialValue: manager.account.balance)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    BalanceRow(balance: $balance, currency: $currency, isEditMode: $isEditMode)
                    CurrencyRow(currency: $currency, isEditMode: $isEditMode, showPopup: $showPopup)
                }
                .padding(16)
                .frame(maxHeight: .infinity, alignment: .top)
                .toolbar {
                    Button(action: {
                        withAnimation {
                            isEditMode.toggle()
                        }
                    }) {
                        Text(isEditMode ? "Сохранить" : "Редактировать")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.violet)
                    }
                }
                .onChange(of: currency) { _, newValue in
                    bankAccount.updateCurrency(newValue)
                }
                .onChange(of: balance) { _, newValue in
                    let rounded = newValue.rounded(scale: 2)
                    if rounded != newValue {
                        balance = rounded
                    }
                    bankAccount.updateBalance(rounded)
                }
                .overlay(
                    Group {
                        if isEditMode {
                            ZStack {
                                Color.black.opacity(showPopup ? 0.3 : 0)
                                    .ignoresSafeArea()
                                    .animation(.easeInOut(duration: 0.3), value: showPopup)
                                    .onTapGesture {
                                        showPopup = false
                                    }
                                
                                VStack {
                                    Spacer()
                                    
                                    CurrencyPopup(currency: $currency, showPopup: $showPopup)
                                        .padding(.horizontal, 12.5)
                                        .padding(.bottom, 4)
                                        .scaleEffect(showPopup ? 1.0 : 0.5)
                                        .opacity(showPopup ? 1.0 : 0.0)
                                        .animation(.easeInOut, value: showPopup)
                                        .allowsHitTesting(showPopup)
                                }
                            }
                        }
                    }
                )
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private struct BalanceRow: View {
        let emoji: Character = "💰"
        let text: String = "Баланс"
        @Binding var balance: Decimal
        @Binding var currency: Currency
        @Binding var isEditMode: Bool
        
        var body: some View {
            HStack(spacing: 0) {
                Text("💰")
                    .padding(.trailing, 12)
                
                Text("Баланс")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
                
                
                TextField("0", value: $balance, format: .number)
                    .keyboardType(.decimalPad)
                    .disabled(!isEditMode)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(isEditMode ? .textGray : .black)
                    .fixedSize()
                
                if !isEditMode {
                    Text(" \(currency.rawValue)")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                }
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill( isEditMode ? .white : .accent)
            )
        }
    }
    
    private struct CurrencyRow: View {
        let text: String = "Валюта"
        @Binding var currency: Currency
        @Binding var isEditMode: Bool
        @Binding var showPopup: Bool
        
        var body: some View {
            HStack {
                Text("Валюта")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: { showPopup = true }) {
                    Text("\(currency.rawValue)")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(isEditMode ? .textGray : .black)
                }
                .disabled(!isEditMode)
            }
            .padding(11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isEditMode ? .white : .mintGreen)
            )
        }
    }
    
    private struct CurrencyPopup: View {
        @Binding var currency: Currency
        @Binding var showPopup: Bool
        
        var body: some View {
            VStack(spacing: 0) {
                
                Text("Валюта")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.customBlack)
                    .padding(.vertical, 17)
                
                Divider()
                    .padding(.horizontal, 0)
                
                ForEach(Currency.allCases.indices, id: \.self) { index in
                    let item = Currency.allCases[index]
                    
                    Button(action: {
                        self.currency = item
                        self.showPopup = false
                    }) {
                        Text(title(for: item))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.violet)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 17)
                    }
                    
                    if index < Currency.allCases.count - 1 {
                        Divider()
                            .padding(.horizontal, 0)
                    }
                }
            }
            .background(Color.lightGray)
            .cornerRadius(14)
            .shadow(radius: 3)
        }
        
        private func title(for currency: Currency) -> String {
            switch currency {
            case .rub:
                return "Российский рубль ₽"
            case .usd:
                return "Американский доллар $"
            case .eur:
                return "Евро €"
            }
        }
    }
}



#Preview {
    //    currencyPopup(currency: .constant(.rub))
}

