//
//  MeetUpdateRequiredView.swift
//  MeetInfomaniak
//
//  Created by Matthieu on 06.06.2025.
//  Copyright © 2025 Philippe Weidmann. All rights reserved.
//

import DesignSystem
import InfomaniakCoreSwiftUI
import SwiftUI
import VersionChecker

struct MeetUpdateRequiredView: View {
    @Environment(\.openURL) var openURL
    let meetSharedStyle = TemplateSharedStyle(
        background: Assets.SwiftUIColor.backgroundColor,
        titleTextStyle: .init(font: .Meet.title2, color: Assets.SwiftUIColor.textColor),
        descriptionTextStyle: .init(font: .Meet.body, color: Assets.SwiftUIColor.outlineColor),
        buttonStyle: .init(
            background: Assets.SwiftUIColor.infomaniakTintColor,
            textStyle: .init(font: .Meet.headline, color: .white),
            height: IKButtonHeight.large,
            radius: IKRadius.large
        )
    )

    var body: some View {
        UpdateRequiredView(
            image: Image("laptop-stars-rocket"),
            sharedStyle: meetSharedStyle
        ) {
            openURL(Constants.appStore)
        }
    }
}

#Preview {
    MeetUpdateRequiredView()
}
