import SwiftUI

extension Decimal {
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }
}

struct BankAccountView: View {
    @State private var showPopup: Bool = false
    @State var viewModel: BankAccountViewModel = BankAccountViewModel()
    
    var body: some View {
        ScrollView {
            BalanceRow
            CurrencyRow
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            Button(action: {
                viewModel.toggleEditMode()
            }) {
                Text(viewModel.isEditMode ? "Сохранить" : "Редактировать")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.violet)
            }
        }
        .onShake {
            viewModel.isSpoilerOn.toggle()
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
                .presentationDetents([.height(300)])
                .presentationBackground(.clear)
                //По какой-то причине, если не задать padding пропадает первый divider ¯\_(ツ)_/¯
                .padding(.bottom, 30)
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
                Text(viewModel.balanceText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
                    .spoiler(isOn: $viewModel.isSpoilerOn)
                
                Text(" \(viewModel.currency.rawValue)")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.black)
            } else {
                TextField("Введите баланс", text: $viewModel.balanceText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(viewModel.isEditMode ? .textGray : .black)
                    .fixedSize()
                    .onTapGesture {
                        // При первом нажатии очищаем поле и запоминаем оригинальное значение
                        //                        if !hasUserInput {
                        //                            originalBalanceText = balanceText
                        //                            balanceText = ""
                        //                            hasUserInput = true
                        //                        }
                    }
//                    .onChange(of: balanceText) { _, newValue in
                        //                            handleBalanceTextChange(newValue)
//                    }
//                    .onSubmit {
                        // При отправке (скрытии клавиатуры) проверяем, был ли введен текст
//                        if balanceText.isEmpty {
                            //                            balanceText = originalBalanceText
                            //                            hasUserInput = false
//                        }
//                    }
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
}

#Preview {
    //    currencyPopup(currency: .constant(.rub))
}

