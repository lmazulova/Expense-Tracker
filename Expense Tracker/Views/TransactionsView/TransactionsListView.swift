import SwiftUI
import OSLog

struct TransactionsListView: View {
    @State var isModalPresented: Bool = false
    private var direction: Direction
    @State var selectedTransaction: Transaction?
    
    private var startDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var endDate: Date {
        let calendar = Calendar.current
        let today = Date()
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today) ?? today
    }
    
    private var transactionService = TransactionsService.shared
    @State private var transactions: [Transaction] = []
    @State private var showHistory: Bool = false
    
    private var sumOfTransactions: Decimal {
        var result: Decimal = 0
        for transaction in transactions {
            result += transaction.amount
        }
        return result
    }
    
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "TransactionParser"
    )
    
    init(direction: Direction) {
        self.direction = direction
    }
    var body: some View {
        ZStack {
            VStack {
                List {
                    amountView
                    
                    Section("Операции") {
                        ForEach(Array(transactions.enumerated()), id: \.element) { index, transaction in
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
                    }
                }
            }
            .onChange(of: selectedTransaction) { _, newValue in
                if newValue != nil {
                    isModalPresented = true
                }
            }
            .navigationDestination(isPresented: $showHistory) {
                HistoryView(viewModel: HistoryViewModel(direction: direction))
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showHistory = true }) {
                    Image("historyButton")
                }
            }
        }
        .task {
            await loadTransactions()
        }
        .fullScreenCover(isPresented: $isModalPresented, onDismiss: {
            selectedTransaction = nil
        }) {
            TransactionCreationView(direction: direction, selectedTransaction: selectedTransaction)
        }
    }
    
    private var amountView: some View {
        HStack {
            Text("Всего")
                .font(.system(size: 17, weight: .regular))
            Spacer()
            Text("\(sumOfTransactions) \(transactions.first?.account.currency.rawValue ?? "")")
                .font(.system(size: 17, weight: .regular))
        }
    }
    
    private func loadTransactions() async {
        do {
            transactions = try await transactionService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
        }
        catch {
            os_log("‼️ Ошибка загрузки транзакций.",
                   log: log,
                   type: .error)
            
            transactions = []
        }
    }
}

private enum ViewConstants {
    static let iconSize: Double = 56
}

#Preview {
    TransactionsListView(direction: .income)
}

