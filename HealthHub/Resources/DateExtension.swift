//
//  DateExtension.swift
//  HealthHub
//
//  Created by Carlotta Chen on 3/2/22.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
