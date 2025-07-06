//
//  CurrencySelectionView.swift
//  Expense Tracker
//
//  Created by user on 05.07.2025.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Binding var currency: Currency
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text("Валюта")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.customBlack)
                .padding(.vertical, 17)
            
            Divider()
                .background(Color.textGray)
            
            ForEach(Currency.allCases.indices, id: \.self) { index in
                let item = Currency.allCases[index]
                
                Button(action: {
                    self.currency = item
                    dismiss()
                }) {
                    Text(title(for: item))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.violet)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 17)
                }
                
                if index < Currency.allCases.count - 1 {
                    Divider()
                }
            }
        }
        .background(Color.customLightGray)
        .cornerRadius(14)
        .shadow(radius: 3)
    }
    
    private func title(for currency: Currency) -> String {
        switch currency {
        case .rub:
            return "Российский рубль ₽"
        case .usd:
            return "Американский доллар $"
        case .eur:
            return "Евро €"
        }
    }

}

