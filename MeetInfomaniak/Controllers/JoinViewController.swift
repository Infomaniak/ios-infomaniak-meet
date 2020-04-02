//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!

    let hashCharList = Array("abcdefghijklmnopqrstuvwxyz")
    var roomId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        fieldsView.layer.cornerRadius = 10
        fieldsView.layer.shadowColor = UIColor.black.cgColor
        fieldsView.layer.shadowOpacity = 0.25
        fieldsView.layer.shadowOffset = .zero
        fieldsView.layer.shadowRadius = 10

        self.setCreateButtonEnabled(false)

        if roomId == nil {
            roomId = String((0..<16).map { _ in hashCharList.randomElement()! })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(JoinViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let conferenceViewController = segue.destination as? ConferenceViewController {
            conferenceViewController.roomName = roomId
            conferenceViewController.displayName = usernameTextField.text!
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://meet.infomaniak.com/\(roomId!)") {
            let activityVC = UIActivityViewController(activityItems: ["kMeet", "shareText".localized, url] as [Any], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction func usenameChanged(_ sender: UITextField) {
        self.setCreateButtonEnabled(sender.text!.count > 1)
    }

    func setCreateButtonEnabled(_ enabled: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.createButton.isEnabled = enabled
            self.createButton.backgroundColor = enabled ? UIColor(named: "mainTint") : UIColor.lightGray
        }
    }

    // MARK: - Keyboard management

    @objc func keyboardWillChange(notification: Notification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.view.frame.origin.y += deltaY
            self.view.setNeedsLayout()
        }, completion: nil)

    }

}
