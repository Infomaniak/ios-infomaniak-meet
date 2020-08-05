//
//  ConferenceViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit
import JitsiMeet

class ConferenceViewController: UIViewController, JitsiMeetViewDelegate {

    var displayName: String!
    var roomName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        let jitsiView = self.view as! JitsiMeetView
        jitsiView.delegate = self
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.room = self.roomName
            builder.userInfo = JitsiMeetUserInfo(displayName: self.displayName, andEmail: nil, andAvatar: nil)
        }
        jitsiView.join(options)
    }

    func conferenceTerminated(_ data: [AnyHashable: Any]!) {
        navigationController?.popViewController(animated: true)
    }

}
