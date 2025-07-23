import SwiftUI

struct TransactionsListView: View {
    @State var isModalPresented: Bool = false
    @State var selectedTransaction: Transaction?
    @State var viewModel: TransactionListViewModel
    @State private var showHistory: Bool = false
    @State var firstRequest: Bool = true
    @Environment(DataProvider.self) private var dataProvider
    
    init(direction: Direction) {
        self._viewModel = State(
            wrappedValue: TransactionListViewModel(direction: direction)
        )
    }
    
    var body: some View {
        ZStack {
            if viewModel.state == .loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    List {
                        amountView
                        
                        Section("Операции") {
                            ForEach(Array(viewModel.transactions.enumerated()), id: \.element) { index, transaction in
                                transactionRow(index: index, transaction: transaction)
                            }
                        }
                    }
                }
                .onChange(of: selectedTransaction) { _, newValue in
                    if newValue != nil {
                        isModalPresented = true
                    }
                }
                .navigationDestination(isPresented: $showHistory) {
                    HistoryView(viewModel: HistoryViewModel(transactionService: viewModel.transactionsService, direction: viewModel.direction))
                        .navigationTitle("Моя история")
                }
                .navigationDestination(for: Transaction.self) { transaction in
                    
                }
                Button(action: {
                    isModalPresented = true
                }) {
                    Image("addButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: ViewConstants.iconSize, height: ViewConstants.iconSize)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 16))
            }
        }
        .task {
            if viewModel.transactionsService == nil {
                viewModel.transactionsService = TransactionsService(
                    localStorage: dataProvider.transactionStorage,
                    bankAccountStorage: dataProvider.bankAccountStorage
                )
            }
            if viewModel.categoriesService == nil {
                viewModel.categoriesService = CategoriesService(localStorage: dataProvider.categoryStorage)
            }
            await viewModel.loadTransactions()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showHistory = true }) {
                    Image("historyButton")
                }
            }
        }
        .fullScreenCover(isPresented: $isModalPresented, onDismiss: {
            selectedTransaction = nil
            Task {
                await viewModel.loadTransactions()
            }
        }) {
            TransactionCreationView(
                direction: viewModel.direction,
                selectedTransaction: selectedTransaction,
                transactionsService: viewModel.transactionsService,
                categoriesService: viewModel.categoriesService
            )
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
    
    private func transactionRow(index: Int, transaction: Transaction) -> some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.leading, 30)
                .opacity(index == 0 ? 0 : 1)
            HStack {
                TransactionRowView(transaction: transaction)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.textGray)
            }
            .padding(.trailing, 16)
            Divider()
                .padding(.leading, 30)
                .opacity(0)
        }
        .onTapGesture {
            selectedTransaction = transaction
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
    }
    
    private var amountView: some View {
        HStack {
            Text("Всего")
                .font(.system(size: 17, weight: .regular))
            Spacer()
            Text("\(viewModel.sumOfTransactions) \(viewModel.transactions.first?.account.currency.rawValue ?? "")")
                .font(.system(size: 17, weight: .regular))
        }
    }
}

private enum ViewConstants {
    static let iconSize: Double = 56
}

#Preview {
    //    TransactionsListView(direction: .income)
}

