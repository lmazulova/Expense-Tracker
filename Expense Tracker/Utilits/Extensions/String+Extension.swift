//
//  String+Extension.swift
//  Expense Tracker
//
//  Created by user on 10.07.2025.
//

import Foundation

extension String {
    func decimalFromLocalizedString(locale: Locale = .current) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        if let number = formatter.number(from: self) {
            return number.decimalValue
        }
        return nil
    }
}
