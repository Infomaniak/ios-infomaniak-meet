//
//  UIButton+Extension.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 11.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

extension UIButton {
    func setLoading(_ loading: Bool) {
        self.isEnabled = !loading
        if loading {
            self.setTitle("", for: .disabled)
            let loadingSpinner = UIActivityIndicatorView(style: .white)
            loadingSpinner.startAnimating()
            loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
            loadingSpinner.hidesWhenStopped = true
            self.addSubview(loadingSpinner)
            loadingSpinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingSpinner.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        } else {
            self.setTitle(self.title(for: .normal), for: .disabled)
            for view in self.subviews {
                if view.isKind(of: UIActivityIndicatorView.self) {
                    view.removeFromSuperview()
                }
            }
        }
    }
}
