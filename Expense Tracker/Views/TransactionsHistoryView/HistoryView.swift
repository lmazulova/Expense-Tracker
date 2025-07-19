import SwiftUI
import OSLog

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: HistoryViewModel
    @State var showAnalysisView: Bool = false
    
    private let log = OSLog(
        subsystem: "ru.lmazulova.Expense-Tracker",
        category: "HistoryView"
    )
    
    init(viewModel: HistoryViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            List {
                startDateRow
                endDateRow
                sortRow
                amountRow
                
                if viewModel.state == .loading {
                    ProgressView()
                } else {
                    Section("Операции") {
                        ForEach(Array(viewModel.sortedTransactions.enumerated()), id: \.element.id) { index, transaction in
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton(action: {dismiss()})
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showAnalysisView = true }) {
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
                    SortView(selectedOption: viewModel.selectedOption, selectedOrder: viewModel.selectedOrder) { option, order in
                        viewModel.setFilters(option: option, order: order)
                    } onReset: {
                        viewModel.resetFilters()
                    }
                    .frame(height: 310)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 10)
                    )
                    .padding()
                }
                .opacity(viewModel.showSortView ? 1 : 0)
                .animation(.easeInOut, value: viewModel.showSortView)
            }
        )
        .task {
            await viewModel.loadTransactions()
        }
        .fullScreenCover(isPresented: $showAnalysisView) {
            AnalysisView(direction: viewModel.direction)
                .ignoresSafeArea()
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
    
    private var startDateRow: some View {
        HStack {
            Text("Начало")
                .font(.system(size: 17, weight: .regular))
            
            Spacer()
            
            CustomDatePicker(selectedDate: $viewModel.startDate)
        }
    }
    
    private var endDateRow: some View {
        HStack {
            Text("Конец")
                .font(.system(size: 17, weight: .regular))
            
            Spacer()
            
            CustomDatePicker(selectedDate: $viewModel.endDate)
        }
    }
    
    private var sortRow: some View {
        Button(action: { viewModel.showSortView = true }) {
            HStack {
                Text("Сортировка")
                    .font(.system(size: 17, weight: .regular))
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
            
            Text("\(viewModel.sumOfTransactions) \(viewModel.currency.rawValue)")
                .font(.system(size: 17, weight: .regular))
        }
    }
}

#Preview {
//    HistoryView(transactionsService: TransactionsService(), direction: .income)
}

