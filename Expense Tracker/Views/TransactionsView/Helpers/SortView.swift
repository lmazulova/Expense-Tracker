//
//  SortingView.swift
//  Expense Tracker
//
//  Created by user on 20.06.2025.
//

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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 50) {
            VStack(alignment: .leading, spacing: 30) {
                
                Text("Настройки сортировки")
                    .font(.title2)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading) {
                    Section(header:
                                Text("Сортировать по")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                    ) {
                        Picker("Sort by", selection: $selectedOption) {
                            ForEach(SortingOption.allCases.filter { $0 != .none }, id: \.self) { option in
                                Text(option == .amount ? "Сумма" : "Дата").tag(option)
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Section(header:
                                Text("Порядок сортировки")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                    ) {
                        Picker("Order", selection: $selectedOrder) {
                            ForEach(SortingOrder.allCases.filter { $0 != .none }, id: \.self) { order in
                                Text(order == .ascending ? "По возрастанию" : "По убыванию").tag(order)
                            }
                        }
                    }
                }
            }
            .pickerStyle(.segmented)
            .listSectionSpacing(0)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            
            HStack(spacing: 10) {
                Button(action: {
                    selectedOption = .none
                    selectedOrder = .none
                    showSortView = false
                }) {
                    Text("Сбросить фильтры")
                        .font(.system(size: 15))
                        .foregroundColor(.black)
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
                                .fill(Color.accentColor)
                        )
                }
            }
        }
        .padding(.horizontal, 15)
    }
}

