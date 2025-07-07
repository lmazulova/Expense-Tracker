import SwiftUI

enum SortingOption: CaseIterable {
    case amount
    case date
    case none
}

enum SortingOrder: CaseIterable {
    case ascending
    case descending
    case none
}

struct SortView: View {
    @Binding var showSortView: Bool
    @Binding var selectedOption: SortingOption
    @Binding var selectedOrder: SortingOrder
    private var isDoneButtonDisabled: Bool {
        selectedOption == .none || selectedOrder == .none
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Настройки сортировки")
                .font(.title2)
                .foregroundColor(.black)
            
            List {
                Section("Сортировать по") {
                    Picker("Sort by", selection: $selectedOption) {
                        ForEach(SortingOption.allCases.filter { $0 != .none }, id: \.self) { option in
                            Text(option == .amount ? "Сумма" : "Дата").tag(option)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
                Section("Порядок сортировки") {
                    Picker("Order", selection: $selectedOrder) {
                        ForEach(SortingOrder.allCases.filter { $0 != .none }, id: \.self) { order in
                            Text(order == .ascending ? "По возрастанию" : "По убыванию").tag(order)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .pickerStyle(.segmented)
            .listSectionSpacing(0)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            
            HStack(spacing: 10) {
                Button(action: {
                    selectedOption = .none
                    selectedOrder = .none
                    showSortView = false
                }) {
                    Text("Сбросить фильтры")
                        .font(.system(size: 15))
                        .foregroundColor(.customRed)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.backgroundGray)
                        )
                }
                Button(action: { showSortView = false }) {
                    Text("Готово")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isDoneButtonDisabled ? Color.mintGreen : Color.accentColor)
                        )
                }
                .disabled(isDoneButtonDisabled)
                .animation(.easeInOut, value: isDoneButtonDisabled)
            }
        }
        .padding(15)
    }
}

