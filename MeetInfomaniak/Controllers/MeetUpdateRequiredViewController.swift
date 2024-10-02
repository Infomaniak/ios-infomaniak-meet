//
//  MeetUpdateRequiredViewController.swift
//  MeetInfomaniak
//
//  Created by Matthieu on 01.10.2024.
//  Copyright © 2024 Philippe Weidmann. All rights reserved.
//

import InfomaniakCoreCommonUI
import SwiftUI
import UIKit
import VersionChecker

class MeetUpdateRequiredViewController: UIViewController {

    private let sharedStyle = TemplateSharedStyle(
        background: Color("buttonsView"),
        titleTextStyle: .init(font: Font(TextStyle.header2.font), color: Color(TextStyle.header2.color)),
        descriptionTextStyle: .init(font: Font(TextStyle.body1.font), color: Color(TextStyle.body1.color)),
        buttonStyle: .init(
            background: Color("infomaniakTint"),
            textStyle: .init(font: Font(UIFont.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .medium)), color: Color(.secondaryTint)),
            height: 50,
            radius: UIConstants.buttonsRadius
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingViewController = UIHostingController(rootView: UpdateRequiredView(
            image: Image("updateRequired"),
            sharedStyle: sharedStyle,
            updateHandler: updateApp
        ))
        guard let hostingView = hostingViewController.view else { return }

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addChild(hostingViewController)
        view.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        hostingViewController.didMove(toParent: self)
    }

    private func updateApp() {
        let url: URLConstants = .appStore
        UIConstants.openURL(url.url, from: self)
    }
}

@available(iOS 17.0, *)
#Preview {
    return MeetUpdateRequiredViewController()
}
