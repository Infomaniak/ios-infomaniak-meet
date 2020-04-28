//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var joinMeetingButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    var fieldsViewFrame: CGRect!

    let hashCharList = Array("abcdefghijklmnopqrstuvwxyz")
    var roomId: String!
    var shouldAutoJoin = false
    let username = UserDefaults.getUsername()
    var alertController: UIAlertController!
    var joinAction: UIAlertAction!
    var alertPresented = false

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
            roomId = generateRoomId()
        } else {
            joinMeetingButton.isHidden = true
        }

        if username != nil {
            usernameTextField.text = username
        }

        self.createAlertViewController()
        self.setCreateButtonEnabled(true)
    }
    
    func generateRoomId() -> String {
        return String((0..<16).map { _ in hashCharList.randomElement()! })
    }

    func createAlertViewController() {
        alertController = UIAlertController(title: "joinRoomTitle".localized, message: "joinRoomAlertDescription".localized, preferredStyle: UIAlertController.Style.alert)
        alertController.view.tintColor = UIColor(named: "mainTint")

        joinAction = UIAlertAction(title: "joinRoomButton".localized, style: UIAlertAction.Style.default, handler: { alert -> Void in
            let roomName = self.alertController.textFields![0] as UITextField
            self.performSegue(withIdentifier: "ConferenceSegue", sender: roomName.text)
            self.alertPresented = false
        })
        joinAction.isEnabled = false

        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "roomNameHint".localized
            textField.addTarget(self, action: #selector(self.roomNameChanged(_:)), for: .editingChanged)
        }

        let cancelAction = UIAlertAction(title: "cancelButton".localized, style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) -> Void in
            self.roomId = self.generateRoomId()
            self.alertPresented = false
        })

        alertController.addAction(joinAction)
        alertController.addAction(cancelAction)
    }

    @objc func roomNameChanged(_ sender: UITextField) {
        joinAction.isEnabled = sender.text!.count > 3
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (usernameTextField.text!.count > 1) {
            return true
        } else {
            UIView.animate(withDuration: 0.5) {
                self.errorLabel.alpha = 1
            }
            return false
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        fieldsViewFrame = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        if shouldAutoJoin && usernameTextField.text!.count > 1 {
            self.performSegue(withIdentifier: "ConferenceSegue", sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(JoinViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        createButton.setTitle(shouldAutoJoin ? "acceptButton".localized : "createButton".localized, for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let conferenceViewController = segue.destination as? ConferenceViewController {
            shouldAutoJoin = false
            UserDefaults.store(username: usernameTextField.text!)
            conferenceViewController.roomName = (sender as? String ?? roomId)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            conferenceViewController.displayName = usernameTextField.text!
        }
    }

    @IBAction func joinMeetingButtonPressed(_ sender: UIButton) {
        if (usernameTextField.text!.count > 1) {
            self.alertPresented = true
            self.present(alertController, animated: true, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5) {
                self.errorLabel.alpha = 1
            }
        }
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "https://meet.infomaniak.com/\(roomId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)") {
            let activityVC = UIActivityViewController(activityItems: ["shareText".localized, url] as [Any], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = shareButton
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @IBAction func usenameChanged(_ sender: UITextField) {
        if (usernameTextField.text!.count > 1) {
            UIView.animate(withDuration: 0.5) {
                self.errorLabel.alpha = 0
            }
        }
    }

    func setCreateButtonEnabled(_ enabled: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.createButton.isEnabled = enabled
            self.createButton.backgroundColor = enabled ? UIColor(named: "mainTint") : UIColor.lightGray
        }
    }

    // MARK: - Keyboard management

    @objc func keyboardWillChange(notification: Notification) {
        if alertPresented {
            return
        }

        if (fieldsViewFrame == nil) {
            fieldsViewFrame = fieldsView.frame
        }

        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var deltaY: CGFloat = 0

        let fieldsViewFrameInsideView = self.fieldsView.superview!.convert(fieldsView.frame, to: nil)
        if (fieldsViewFrameInsideView.origin.y + self.fieldsView.frame.height < targetFrame.origin.y) {
            deltaY = fieldsView.frame.origin.y
        } else {
            deltaY = (self.fieldsView.superview?.convert(CGPoint(x: fieldsViewFrameInsideView.origin.x, y: (targetFrame.origin.y - self.fieldsView.frame.height)), from: self.view).y ?? 0) - 24
        }

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
                if (curFrame.origin.y > targetFrame.origin.y) {
                    self.fieldsView.frame.origin.y = deltaY
                    self.backgroundView.alpha = 0.75
                } else {
                    self.fieldsView.frame = self.fieldsViewFrame
                    self.backgroundView.alpha = 0
                }
                self.fieldsView.setNeedsLayout()
            }, completion: nil)

    }

}
