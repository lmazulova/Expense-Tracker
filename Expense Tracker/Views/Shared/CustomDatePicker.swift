//
//  DatePickerButton.swift
//  Expense Tracker
//
//  Created by user on 20.06.2025.
//

import SwiftUI

struct CustomDatePicker: UIViewRepresentable {
    @Binding var date: Date
    var maximumDate: Date = Date()
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(named: "mintGreen")
        container.layer.cornerRadius = 8
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .clear
        picker.maximumDate = maximumDate
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        picker.tintColor = UIColor(named: "AccentColor")
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
        
        context.coordinator.picker = picker
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let picker = context.coordinator.picker {
            picker.date = date
            picker.maximumDate = maximumDate
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomDatePicker
        weak var picker: UIDatePicker?
        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}
