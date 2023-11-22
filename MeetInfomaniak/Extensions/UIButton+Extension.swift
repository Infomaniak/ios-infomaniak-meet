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
        isEnabled = !loading
        if loading {
            setTitle("", for: .disabled)
            let loadingSpinner = UIActivityIndicatorView(style: .white)
            loadingSpinner.startAnimating()
            loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
            loadingSpinner.hidesWhenStopped = true
            addSubview(loadingSpinner)
            loadingSpinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            loadingSpinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        } else {
            setTitle(title(for: .normal), for: .disabled)
            for view in subviews {
                if view.isKind(of: UIActivityIndicatorView.self) {
                    view.removeFromSuperview()
                }
            }
        }
    }
}
