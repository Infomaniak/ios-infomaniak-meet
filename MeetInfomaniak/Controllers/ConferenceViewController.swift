//
//  ConferenceViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import JitsiMeetSDK
import UIKit

class ConferenceViewController: UIViewController, JitsiMeetViewDelegate {
    var displayName: String!
    var roomName: String!
    var host: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        let jitsiView = view as! JitsiMeetView
        jitsiView.delegate = self
        let options = JitsiMeetConferenceOptions.fromBuilder { builder in
            builder.room = self.roomName
            builder.serverURL = self.host
            builder.userInfo = JitsiMeetUserInfo(displayName: self.displayName, andEmail: nil, andAvatar: nil)
        }
        jitsiView.join(options)
    }

    func conferenceTerminated(_ data: [AnyHashable: Any]!) {
        navigationController?.popViewController(animated: true)
    }
}
