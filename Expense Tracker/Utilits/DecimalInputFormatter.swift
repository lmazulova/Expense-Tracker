//
//  DecimalInputFormatter.swift
//  Expense Tracker
//
//  Created by user on 10.07.2025.
//

import Foundation

struct DecimalInputFormatter {
    static func filterInput(input: String) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let allowedChars = CharacterSet(charactersIn: "1234567890" + decimalSeparator)
        let filtered = input.filter { String($0).rangeOfCharacter(from: allowedChars) != nil }
        let components = filtered.components(separatedBy: decimalSeparator)
        var integerPart = components.first ?? "0"
        var fractionPart = components.count > 1 ? components[1] : ""
        
        //убираем ведущие нули
        if integerPart.count > 1 {
            if integerPart.first == "0" {
                integerPart = String(integerPart.drop { $0 == "0" })
                if integerPart.isEmpty {
                    integerPart = "0"
                }
            }
        }
        
        if fractionPart.count > 2 {
            fractionPart = String(fractionPart.prefix(2))
        }
        var result = integerPart
        if !fractionPart.isEmpty {
            result += decimalSeparator + fractionPart
        } else if input.contains(decimalSeparator) {
            result += decimalSeparator
        }
        if result.count > 20 {
            result = String(result.prefix(20))
        }
        return result
    }
}
