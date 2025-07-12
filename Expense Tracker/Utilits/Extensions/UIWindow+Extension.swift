//
//  UIWindow + motionEnded.swift
//  Expense Tracker
//
//  Created by user on 27.06.2025.
//

import SwiftUI

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}
