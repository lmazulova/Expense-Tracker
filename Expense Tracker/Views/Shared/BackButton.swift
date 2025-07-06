//
//  File.swift
//  Expense Tracker
//
//  Created by user on 06.07.2025.
//

import SwiftUI

struct BackButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action ) {
            HStack {
                Image(systemName: "chevron.backward")
                    .frame(width: 17, height: 22)
                    .foregroundStyle(Color.violet)
                Text("Назад")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.violet)
            }
        }
    }
}
