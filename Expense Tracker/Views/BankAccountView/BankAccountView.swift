import SwiftUI

struct BankAccountView: View {
    @State private var showPopup: Bool = false
    @State var isSpoilerOn: Bool = false
    @State var viewModel: BankAccountViewModel
    //Переменные для режима редактирования, обновление аккаунта происходит при нажатии на кнопку сохранения
    @State var editBalanceText: String = ""
    @State var editCurrency: Currency = .rub
    @FocusState private var textFieldIsFocused: Bool
    
    init() {
        self._viewModel = State(
            wrappedValue: BankAccountViewModel(
                bankAccountService: BankAccountService(localStorage: BankAccountStorage())
            )
        )
    }
    var body: some View {
        ScrollView {
            BalanceRow
            CurrencyRow
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            Button(
                action: {
                isSpoilerOn = false
                checkLastDigit()
                if viewModel.isEditMode {
                    if viewModel.account?.balance != editBalanceText
                        .decimalFromLocalizedString() || viewModel.account?.currency != editCurrency {
                        Task {
                            await viewModel.updateAccount(
                                balance: editBalanceText.decimalFromLocalizedString() ?? 0,
                                currency: editCurrency
                            )
                        }
                    }
                } else {
                    if let account = viewModel.account {
                        editBalanceText = account.balance.formattedWithLocale()
                        editCurrency = account.currency
                    }
                }
                viewModel.toggleEditMode()
            }) {
                Text(viewModel.isEditMode ? "Сохранить" : "Редактировать")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.violet)
            }
        }
        .task {
            await viewModel.loadAccount()
            editBalanceText = viewModel.account?.balance.formattedWithLocale() ?? "0"
            editCurrency = viewModel.account?.currency ?? .rub
        }
        .onShake {
            isSpoilerOn.toggle()
        }
        .if(viewModel.isEditMode) { view in
            view.scrollDismissesKeyboard(.interactively)
        }
        .if(!viewModel.isEditMode) { view in
            view.refreshable {
                await viewModel.loadAccount()
            }
        }
        .popover(isPresented: $showPopup) {
            CurrencyPickerView(currency: $editCurrency)
                .padding(.horizontal, 12.5)
                .presentationDetents([.height(350)])
                .presentationBackground(.clear)
        }
        .background(Color(.systemGroupedBackground))
        .alert("Упс, что-то пошло не так.", isPresented: .constant({
            if case .error = viewModel.state { return true }
            return false
        }())) {
            Button("Ок", role: .cancel) {
                viewModel.state = .data
            }
        } message: {
            Text(viewModel.state.errorMessage ?? "Уже чиним!")
        }
    }
    
    private var BalanceRow: some View {
        HStack(spacing: 0) {
            Text("💰")
                .padding(.trailing, 12)
            
            Text("Баланс")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.black)
            
            Spacer()
            
            if viewModel.state == .loading {
                ProgressView()
            }
            else if !viewModel.isEditMode {
                Text(viewModel.account?.balance.formattedWithLocale() ?? "0")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                    .spoiler(isOn: $isSpoilerOn)
                
                Text(" \(viewModel.account?.currency.rawValue ?? "₽")")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
            } else {
                TextField("Введите баланс", text: $editBalanceText)
                    .font(.system(size: 17, weight: .regular))
                    .focused($textFieldIsFocused)
                    .foregroundColor(textFieldIsFocused ? .black : .textGray)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .fixedSize()
                    .onChange(of: editBalanceText) { _, newValue in
                        editBalanceText = DecimalInputFormatter.filterInput(input: newValue )
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
            
            if viewModel.state == .loading {
                ProgressView()
            } else {
                Button(action: { showPopup = true }) {
                    Text("\(viewModel.isEditMode ? editCurrency.rawValue : (viewModel.account?.currency.rawValue ?? "₽"))")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(viewModel.isEditMode ? .textGray : .black)
                }
                .disabled(!viewModel.isEditMode)
            }
        }
        .padding(11)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(viewModel.isEditMode ? .white : .mintGreen)
        }
    }
    
    //Проверка, что последний введенный символ не является разделителем
    private func checkLastDigit() {
        if let lastDigit = editBalanceText.last, lastDigit == "." || lastDigit == "," {
            editBalanceText = String(editBalanceText.dropLast())
        }
    }
}

#Preview {
    //    currencyPopup(currency: .constant(.rub))
}

