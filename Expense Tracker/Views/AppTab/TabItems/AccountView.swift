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
    @State var isSpoilerOn: Bool = false
    @State var balanceText: String
    
    init() {
        let manager = BankAccountManager()
        _bankAccount = State(wrappedValue: manager)
        _currency = State(initialValue: manager.account.currency)
        _balance = State(initialValue: manager.account.balance)
        _balanceText = State(initialValue:  "\(manager.account.balance)")
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    BalanceRow(balance: $balance, balanceText: $balanceText, currency: $currency, isEditMode: $isEditMode, isSpoilerOn: $isSpoilerOn)
                    CurrencyRow(currency: $currency, isEditMode: $isEditMode, showPopup: $showPopup)
                }
                .padding(16)
                .frame(maxHeight: .infinity, alignment: .top)
                .toolbar {
                    Button(action: {
                        withAnimation {
                            isEditMode.toggle()
                            isSpoilerOn = false
                            if !isEditMode {
                                // При выходе из режима редактирования обновляем текст
                                balanceText = "\(balance)"
                            }
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
                .onShake {
                    isSpoilerOn.toggle()
                }
            }
            .scrollDismissesKeyboard(.interactively)
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
        .refreshable {
            await bankAccount.requestForUpdate()
        }
    }
    
    private struct BalanceRow: View {
        let emoji: Character = "💰"
        let text: String = "Баланс"
        @Binding var balance: Decimal
        @Binding var balanceText: String
        @Binding var currency: Currency
        @Binding var isEditMode: Bool
        @Binding var isSpoilerOn: Bool
        @State var originalBalanceText: String
        @State var hasUserInput: Bool = false
        
        init(balance: Binding<Decimal>, balanceText: Binding<String>, currency: Binding<Currency>, isEditMode: Binding<Bool>, isSpoilerOn: Binding<Bool>) {
            self._balance = balance
            self._balanceText = balanceText
            self._currency = currency
            self._isEditMode = isEditMode
            self._isSpoilerOn = isSpoilerOn
            self._originalBalanceText = State(initialValue: "\(balance)")
        }
        
        private func handleBalanceTextChange(_ newValue: String) {
            // Ограничиваем длину до 15 символов
            if newValue.count > 15 {
                balanceText = String(newValue.prefix(15))
                return
            }
            
            // Фильтруем только цифры, точку и запятую
            let filtered = newValue.filter { "0123456789.,".contains($0) }
            if filtered != newValue {
                balanceText = filtered
                return
            }
            
            let normalized = filtered.replacingOccurrences(of: ",", with: ".")
            
            // Проверяем формат decimal (максимум одна точка и максимум 2 знака после точки)
            let components = normalized.components(separatedBy: ".")
            if components.count > 2 {
                // Больше одной точки - оставляем только первую
                let beforeDot = components[0]
                let afterDot = components[1]
                let result = "\(beforeDot).\(afterDot)"
                balanceText = result.replacingOccurrences(of: ".", with: filtered.contains(",") ? "," : ".")
                return
            }
            
            if components.count == 2 && components[1].count > 2 {
                // Больше 2 знаков после точки - обрезаем
                let beforeDot = components[0]
                let afterDot = String(components[1].prefix(2))
                let result = "\(beforeDot).\(afterDot)"
                balanceText = result.replacingOccurrences(of: ".", with: filtered.contains(",") ? "," : ".")
                return
            }
            
            // Преобразуем в Decimal и обновляем balance
            if let decimal = Decimal(string: normalized) {
                balance = decimal
            }
        }
        
        var body: some View {
            HStack(spacing: 0) {
                Text("💰")
                    .padding(.trailing, 12)
                
                Text("Баланс")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
                
                if !isEditMode {
                    Text(balanceText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                        .spoiler(isOn: $isSpoilerOn)
                    
                    Text(" \(currency.rawValue)")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.black)
                } else {
                    TextField("0", text: $balanceText)
                        .keyboardType(.decimalPad)
                        .disabled(!isEditMode)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(isEditMode ? .textGray : .black)
                        .fixedSize()
                        .onTapGesture {
                            // При первом нажатии очищаем поле и запоминаем оригинальное значение
                            if !hasUserInput {
                                originalBalanceText = balanceText
                                balanceText = ""
                                hasUserInput = true
                            }
                        }
                        .onChange(of: balanceText) { _, newValue in
                            handleBalanceTextChange(newValue)
                        }
                        .onSubmit {
                            // При отправке (скрытии клавиатуры) проверяем, был ли введен текст
                            if balanceText.isEmpty {
                                balanceText = originalBalanceText
                                hasUserInput = false
                            }
                        }
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

