import SwiftUI

struct TransactionsListView: View {
    @State var isModalPresented: Bool = false
    @State var selectedTransaction: Transaction?
    @State var viewModel: TransactionListViewModel
    @State private var showHistory: Bool = false
    @State var firstRequest: Bool = true
    
    init(viewModel: TransactionListViewModel) {
        self.viewModel = viewModel
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
                    HistoryView(viewModel: HistoryViewModel(direction: viewModel.direction))
                        .navigationTitle("Моя история")
                }
                .navigationDestination(for: Transaction.self) { transaction in
                    
                }
                Button(action: {
                    isModalPresented = true
                }) {
                    Image("plusButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: ViewConstants.iconSize, height: ViewConstants.iconSize)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 16))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showHistory = true }) {
                    Image("historyButton")
                }
            }
        }
        .task {
            //Костыль, т.к. возникает ошибка высокого уровня, при первой инициализации видимо
            //не все свойства для составления запроса инициализируются вовремя, поэтому искусственно ждем 3 секунды
            if firstRequest {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
            await viewModel.loadTransactions()
            firstRequest = false
        }
        .fullScreenCover(isPresented: $isModalPresented, onDismiss: {
            selectedTransaction = nil
            Task {
                await viewModel.loadTransactions()
            }
        }) {
            TransactionCreationView(direction: viewModel.direction, selectedTransaction: selectedTransaction)
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

