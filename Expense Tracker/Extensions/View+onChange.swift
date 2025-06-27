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
