//
//  View+onChange.swift
//  Expense Tracker
//
//  Created by user on 27.06.2025.
//

import SwiftUI

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

extension View {
    /// Применяет какое-либо преобразование View по условию.
    /// - Parameters:
    ///   - condition: условие применения
    ///   - transform: преобразование view
    /// - Returns: в случае true применяет преобразование, в случае false возвращает self
    ///
    /// Пример использования:
    /// ```swift
    /// Text("Hello")
    ///     .if(isRed) { $0.foregroundColor(.red) }
    /// ```
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
