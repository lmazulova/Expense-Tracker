//
//  TransactionCreationView.swift
//  Expense Tracker
//
//  Created by user on 10.07.2025.
//

import Foundation
import SwiftUI

struct TransactionCreationView: View {
    @State private var viewModel: TransactionCreationViewModel
    @FocusState private var textFieldIsFocused: Bool
    @State private var direction: Direction
    @Environment(\.dismiss) private var dismiss
    @State var showAlert: Bool = false
    
    private var isDoneButtonDisabled: Bool {
        viewModel.amountText.isEmpty || viewModel.selectedCategory == nil
    }
    
    init(
        direction: Direction,
        selectedTransaction: Transaction? = nil,
        transactionsService: TransactionsService,
        categoriesService: CategoriesService
    ) {
        self.direction = direction
        _viewModel = State(
            wrappedValue: TransactionCreationViewModel(
                direction: direction,
                selectedTransaction: selectedTransaction,
                transactionService: transactionsService,
                categoriesService: categoriesService
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                categoryView
                amountView
                dateView
                timeView
                commentView
                
                if viewModel.isEditMode {
                    Section {
                        VStack(alignment: .leading) {
                            deleteButton
                        }
                        .padding(.top, 20)
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle ( direction == .outcome ? "Мои расходы" : "Мои доходы" )
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.violet)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditMode ? "Сохранить" : "Создать") {
                        if isDoneButtonDisabled {
                            showAlert = true
                            return
                        }
                        if viewModel.isEditMode {
                            Task {  @MainActor in
                                await viewModel.editTransaction()
                                dismiss()
                            }
                        } else {
                            Task {  @MainActor in
                                await viewModel.createTransaction()
                                dismiss()
                            }
                        }
                    }
                    .foregroundColor(.violet)
                }
            }
            .confirmationDialog(
                "Выберите категорию",
                isPresented: $viewModel.isChoseCategoryPresented,
                titleVisibility: .visible,
                actions: confirmationDialogContent
            )
            .alert("Пожалуйста, заполните все поля", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .task {
                await viewModel.loadCategories()
            }
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
    }
    
    private var categoryView: some View {
        Button {
            viewModel.isChoseCategoryPresented.toggle()
        } label: {
            HStack {
                Text("Статья")
                    .font(.system(size: 17, weight: .regular))
                Spacer()
                Text(viewModel.selectedCategory?.name ?? "Не выбрано")
                    .foregroundStyle(.textGray)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.textGray)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var amountView: some View {
        HStack {
            Text("Сумма")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.black)
            
            Spacer()
            
            TextField("Сумма операции", text: $viewModel.amountText)
                .font(.system(size: 17, weight: .regular))
                .focused($textFieldIsFocused)
                .foregroundColor(textFieldIsFocused ? .black : .textGray)
                .keyboardType(.decimalPad)
                .fixedSize()
                .multilineTextAlignment(.trailing)
                .onChange(of: viewModel.amountText) { _, newValue in
                    viewModel.amountText = DecimalInputFormatter.filterInput(input: newValue )
                }
                .onChange(of: textFieldIsFocused) {
                    checkLastDigit()
                }
            Text(viewModel.currency.rawValue)
                .foregroundStyle(.textGray)
        }
    }
    
    private var dateView: some View {
        HStack {
            Text("Дата")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.black)
            
            Spacer()
            
            CustomDatePicker(selectedDate: $viewModel.selectedDate)
        }
    }
    
    private var timeView: some View {
        HStack {
            Text("Время")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.black)
            
            Spacer()
            
            CustomTimePicker(selectedTime: $viewModel.selectedTime)
        }
    }
    
    private var commentView: some View {
        HStack {
            TextField("Комментарий", text: $viewModel.comment)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            Task {
                @MainActor in
                await viewModel.deleteTransaction()
                dismiss()
            }
        }) {
            Text("Удалить \(direction == .outcome ? "расход" : "доход")")
                .font(.system(size: 15))
                .foregroundColor(.customRed)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
        }
    }
    
    private func checkLastDigit() {
        if let lastDigit = viewModel.amountText.last, lastDigit == "." || lastDigit == "," {
            viewModel.amountText = String(viewModel.amountText.dropLast())
        }
    }
    
    private func confirmationDialogContent() -> some View {
        ForEach(viewModel.categories, id: \.id) { category in
            Button {
                viewModel.selectedCategory = category
            } label: {
                HStack {
                    Text("\(category.emoji)  \(category.name)")
                }
            }
        }
    }
}

#Preview {
//    TransactionCreationView(selectedDate: Date())
}
