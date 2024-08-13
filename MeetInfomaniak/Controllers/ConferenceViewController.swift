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
    let displayName: String
    let roomName: String
    let host: URL?

    init(displayName: String, roomName: String, host: URL?) {
        self.displayName = displayName
        self.roomName = roomName
        self.host = host
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = JitsiMeetView()
    }

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
    
    func ready(toClose data: [AnyHashable : Any]!) {
        navigationController?.popViewController(animated: true)
    }
}
