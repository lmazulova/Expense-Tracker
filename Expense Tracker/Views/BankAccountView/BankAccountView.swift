import SwiftUI

struct BankAccountView: View {
    @State private var showPopup: Bool = false
    @State var isSpoilerOn: Bool = false
    @State var viewModel: BankAccountViewModel = BankAccountViewModel()
    @State var balanceText: String = ""
    @FocusState private var textFieldIsFocused: Bool
    
    var body: some View {
        ScrollView {
            BalanceRow
            CurrencyRow
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            Button(action: {
                isSpoilerOn = false
                checkLastDigit()
                if viewModel.isEditMode {
                    if let value = balanceText.decimalFromLocalizedString() {
                        viewModel.setBalance(balance: value)
                    }
                } else {
                    balanceText = viewModel.balance.formattedWithLocale()
                }
                viewModel.toggleEditMode()
            }) {
                Text(viewModel.isEditMode ? "Сохранить" : "Редактировать")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.violet)
            }
        }
        .onAppear {
            balanceText = viewModel.balance.formattedWithLocale()
        }
        .onShake {
            isSpoilerOn.toggle()
        }
        .if(viewModel.isEditMode) { view in
            view.scrollDismissesKeyboard(.interactively)
        }
        .if(!viewModel.isEditMode) { view in
            view.refreshable {
                await viewModel.requestForUpdate()
            }
        }
        .popover(isPresented: $showPopup) {
            CurrencyPickerView(currency: $viewModel.currency)
                .padding(.horizontal, 12.5)
                .presentationDetents([.height(350)])
                .presentationBackground(.clear)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var BalanceRow: some View {
        HStack(spacing: 0) {
            Text("💰")
                .padding(.trailing, 12)
            
            Text("Баланс")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.black)
            
            Spacer()
            
            if !viewModel.isEditMode {
                Text(balanceText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                    .spoiler(isOn: $isSpoilerOn)
                
                Text(" \(viewModel.currency.rawValue)")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
            } else {
                TextField("Введите баланс", text: $balanceText)
                    .font(.system(size: 17, weight: .regular))
                    .focused($textFieldIsFocused)
                    .foregroundColor(textFieldIsFocused ? .black : .textGray)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .fixedSize()
                    .onChange(of: balanceText) { _, newValue in
                        balanceText = DecimalInputFormatter.filterInput(input: newValue )
                    }
                    .onChange(of: textFieldIsFocused) {
                        checkLastDigit()
                    }
            }
        }
        .padding(11)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.isEditMode ? .white : .accent)
        }
    }
    
    private var CurrencyRow: some View {
        HStack {
            Text("Валюта")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { showPopup = true }) {
                Text("\(viewModel.currency.rawValue)")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(viewModel.isEditMode ? .textGray : .black)
            }
            .disabled(!viewModel.isEditMode)
        }
        .padding(11)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.isEditMode ? .white : .mintGreen)
        }
    }
    
    //Проверка, что последний введенный символ не является разделителем
    private func checkLastDigit() {
        if let lastDigit = balanceText.last, lastDigit == "." || lastDigit == "," {
            balanceText = String(balanceText.dropLast())
        }
    }
}

#Preview {
    //    currencyPopup(currency: .constant(.rub))
}

