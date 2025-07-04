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
                HStack {
                    Text("Начало")
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    ZStack {
                    
                        Text(startDate.formattedRu())
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            startTextWidth = geometry.size.width
                                        }
                                        .onChange(of: geometry.size.width, initial: true) { _, newValue in
                                            startTextWidth = newValue
                                        }
                                }
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.mintGreen)
                            )
                            .foregroundColor(.black)
                        
                        // кладем datePicker под визуальное отображение с помощью модификатора blendMode, но выше в стэке, так он остается кликабельным и при этом не виден на экране
                        DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .blendMode(.destinationOver)
                            .allowsHitTesting(true)
                            .frame(width: startTextWidth)
                    }
                }
                
                HStack {
                    Text("Конец")
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    ZStack {
                    
                        Text(endDate.formattedRu())
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            endTextWidth = geometry.size.width
                                        }
                                        .onChange(of: geometry.size.width, initial: true) { _, newValue in
                                            endTextWidth = newValue
                                        }
                                }
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.mintGreen)
                            )
                            .foregroundColor(.black)
                        
                        // кладем datePicker под визуальное отображение с помощью модификатора blendMode, но выше в стэке, так он остается кликабельным и при этом не виден на экране
                        DatePicker("", selection: $endDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .blendMode(.destinationOver)
                            .allowsHitTesting(true)
                            .frame(width: endTextWidth)
                    }
                    
                }
                HStack {
                    Text("Сортировка")
                        .font(.system(size: 17, weight: .regular))
                    if selectedOption != .none {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8, alignment: .bottom)
                            .padding(0)
                    }
                }
                .onTapGesture {
                    showSortView = true
                }

                HStack {
                    Text("Всего")
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer()
                    
                    Text("\(sumOfTransactions) \(transactions.first?.account.currency.rawValue ?? "")")
                        .font(.system(size: 17, weight: .regular))
                }
                
                Section("Операции") {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
        }
        
        .navigationBarBackButtonHidden(true)
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
                Button(action: {dismiss()}) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .frame(width: 17, height: 22)
                            .foregroundStyle(Color.violet)
                        Text("Назад")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color.violet)
                    }
                }
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
                if showSortView {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { showSortView = false }
                        SortView(showSortView: $showSortView, selectedOption: $selectedOption, selectedOrder: $selectedOrder)
                            .frame(width: 350, height: 370)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 10)
                            )
                            .padding()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showSortView)
                }
            }
        )
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

