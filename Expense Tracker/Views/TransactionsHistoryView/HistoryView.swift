import SwiftUI
import OSLog

struct HistoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var transactions: [Transaction] = []
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var startTextWidth: CGFloat = 0
    @State private var endTextWidth: CGFloat = 0
    @State var selectedOption: SortingOption = .none
    @State var selectedOrder: SortingOrder = .none
    @State private var showSortView: Bool = false
    
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "HistoryView"
    )
    
    private var sumOfTransactions: Decimal {
        var result: Decimal = 0
        for transaction in transactions {
            result += transaction.amount
        }
        return result
    }
    
    private var transactionService: TransactionsService
    private var direction: Direction
    
    init(transactionService: TransactionsService = TransactionsService(), direction: Direction) {
        let initialStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        _startDate = State(initialValue: Calendar.current.startOfDay(for: initialStartDate))
        _endDate = State(initialValue: Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date())
        self.transactionService = transactionService
        self.direction = direction
    }
    
    var body: some View {
        VStack {
            List {
                startDateRow
                endDateRow
                sortRow
                amountRow
                
                Section("Операции") {
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        VStack(spacing: 0) {
                            Divider()
                                .padding(.leading, 30)
                                .opacity(index == 0 ? 0 : 1)
                            
                            TransactionRowView(transaction: transaction)
                            
                            Divider()
                                .padding(.leading, 30)
                                .opacity(0)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
//     Это все перенесу в VM
        .onChange(of: startDate, initial: true) { _, newValue in
            startDate = Calendar.current.startOfDay(for: newValue)
            if startDate > endDate {
                endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: newValue) ?? newValue
            }
            Task {
                await loadTransactions()
            }
        }
        .onChange(of: endDate) { _, newValue in
            endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: newValue) ?? newValue
            if endDate < startDate {
                startDate = Calendar.current.startOfDay(for: newValue)
            }
            Task {
                await loadTransactions()
            }
        }
        .onChange(of: selectedOrder) { _, _ in
            Task {
                await loadTransactions()
            }
        }
        .onChange(of: selectedOption) { _, _ in
            Task {
                await loadTransactions()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: {dismiss()})
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image("analyseButton")
                        .foregroundStyle(Color.violet)
                }
            }
        }
        .overlay(
            Group {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showSortView = false }
                    SortView(showSortView: $showSortView, selectedOption: $selectedOption, selectedOrder: $selectedOrder)
                        .frame(height: 310)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 10)
                        )
                        .padding()
                }
                .opacity(showSortView ? 1 : 0)
                .animation(.easeInOut, value: showSortView)
            }
        )
    }
    
    private var startDateRow: some View {
        HStack {
            Text("Начало")
                .font(.system(size: 17, weight: .regular))
            
            Spacer()
            
            CustomDatePicker(selectedDate: $startDate)
        }
    }
    
    private var endDateRow: some View {
        HStack {
            Text("Конец")
                .font(.system(size: 17, weight: .regular))
            
            Spacer()
            
            CustomDatePicker(selectedDate: $endDate)
        }
    }
    
    private var sortRow: some View {
        Button(action: { showSortView = true }) {
            HStack {
                Text("Сортировка")
                    .font(.system(size: 17, weight: .regular))
                if selectedOption != .none {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8, alignment: .bottom)
                        .padding(0)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var amountRow: some View {
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
            let newTransactions = try await transactionService.getTransactions(from: startDate, to: endDate)
                .filter{ $0.category.direction == direction }
            
            //Применяем фильтрацию по выбранной категории
            switch selectedOption {
            case .date:
                switch selectedOrder {
                case .ascending:
                    transactions = newTransactions.sorted { $0.transactionDate < $1.transactionDate }
                case .descending:
                    transactions = newTransactions.sorted { $0.transactionDate > $1.transactionDate }
                case .none:
                    transactions = newTransactions
                }
            case .amount:
                switch selectedOrder {
                case .ascending:
                    transactions = newTransactions.sorted { $0.amount < $1.amount }
                case .descending:
                    transactions = newTransactions.sorted { $0.amount > $1.amount }
                case .none:
                    transactions = newTransactions
                }
            case .none:
                transactions = newTransactions
            }
        }
        catch {
            os_log("‼️ Ошибка загрузки транзакций.",
                   log: log,
                   type: .error)
            
            transactions = []
        }
    }
}

    
    

#Preview {
    HistoryView(transactionService: TransactionsService(), direction: .income)
}

