//
//  Utils.swift
//  AnkitSypneiOSAssessment
//
//  Created by Ankit yadav on 22/11/24.
//

import Foundation

import UIKit

class Utils {

    static func showToast(message: String, on view: UIView, duration: Double = 1.5) {
        // Create the toast label
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.numberOfLines = 0
        
        // Adjust the size and position
        toastLabel.frame = CGRect(x: view.frame.size.width / 2 - 150,
                                  y: view.frame.size.height - 100,
                                  width: 300,
                                  height: 35)
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        // Add to the view
        view.addSubview(toastLabel)

        // Animation for showing and hiding
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
