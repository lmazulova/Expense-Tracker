//
//  DatePickerButton.swift
//  Expense Tracker
//
//  Created by user on 20.06.2025.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    @State var textWidth: CGFloat = 0
    
    var body: some View {
        ZStack {
            Text(selectedDate.formattedRu())
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.size.width, initial: true) { _, newValue in
                                textWidth = newValue
                            }
                    }
                )
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.mintGreen)
                )
                .foregroundColor(.black)
            
            // кладем datePicker под визуальное отображение с помощью модификатора blendMode, но выше в стэке, так он остается кликабельным и при этом не виден на экране
            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .blendMode(.destinationOver)
                .allowsHitTesting(true)
                .frame(width: textWidth)
        }
    }
}
