//
//  InitialViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 05.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import DesignSystem
import InfomaniakCoreSwiftUI
import OSLog
import SwiftUI
import UIKit
import VersionChecker

class InitialViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let transparentAppearance = UINavigationBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            navigationController?.navigationBar.standardAppearance = transparentAppearance
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        navigationController?.navigationBar.tintColor = Assets.infomaniakTintColor
        checkAppVersion()
    }

    private func checkAppVersion() {
        Task {
            do {
                let versionStatus = try await VersionChecker.standard.checkAppVersionStatus(platform: .ios)

                DispatchQueue.main.async {
                    if versionStatus == .updateIsRequired {
                        let view = MeetUpdateRequiredView()
                        let controller = UIHostingController(rootView: view)
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true)
                    } else if versionStatus == .canBeUpdated {
                        let viewControllerToPresent = UpdateVersionBridgeViewController.instantiate()
                        if let sheet = viewControllerToPresent.sheetPresentationController {
                            if #available(iOS 16.0, *) {
                                sheet.detents = [
                                    .custom { _ in
                                        return 510
                                    }
                                ]
                            } else {
                                sheet.detents = [.large()]
                                sheet.largestUndimmedDetentIdentifier = .large
                            }
                            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                            sheet.prefersEdgeAttachedInCompactHeight = true
                            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                            sheet.prefersGrabberVisible = true
                        }
                        self.present(viewControllerToPresent, animated: true)
                    }
                }
            } catch {
                Logger.view.error("Error while checking version status: \(error)")
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let joinViewController = segue.destination as? JoinViewController {
            joinViewController.joining = segue.identifier == "joinMeetingSegue"
        }
    }

    class func instantiate() -> InitialViewController {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
    }
}
