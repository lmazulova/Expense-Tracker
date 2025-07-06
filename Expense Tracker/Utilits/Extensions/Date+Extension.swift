//
//  Date+Format.swift
//  Expense Tracker
//
//  Created by user on 20.06.2025.
//

import SwiftUI

extension Date {
    func formattedRu() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        
        return formatter.string(from: self)
    }
}
