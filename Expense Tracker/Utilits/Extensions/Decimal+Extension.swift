//
//  Decimal+Extension.swift
//  Expense Tracker
//
//  Created by user on 10.07.2025.
//

import Foundation

extension Decimal {
    func formattedWithLocale(style: NumberFormatter.Style = .decimal, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.locale = locale
        return formatter.string(for: self) ?? "\(self)"
    }
}
