//
//  Design.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/20/22.
//

import UIKit

extension UIView {
    func verticalGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor,
            #colorLiteral(red: 0.6511748433, green: 0.8246683478, blue: 0.9792008996, alpha: 1).cgColor,
            #colorLiteral(red: 0.651250124, green: 0.8244121671, blue: 0.9779451489, alpha: 1).cgColor,
            #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.8)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.2)

        self.layer.insertSublayer(gradient, at: 0)
    }
}
