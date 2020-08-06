//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields

class JoinViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: MDCTextField!
    @IBOutlet weak var roomLinkTextField: MDCTextField!
    @IBOutlet weak var joinMeetingButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    private var usernameFieldController: MDCTextInputControllerOutlined?
    private var roomLinkFieldController: MDCTextInputControllerOutlined?

    private let hashCharList = Array("abcdefghijklmnopqrstuvwxyz")
    private var roomId: String!
    private let username = UserDefaults.getUsername()

    var joinUrl: URL?
    var joining = false

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
        navigationController?.navigationBar.tintColor = UIColor(named: "infomaniakTint")

        self.hideKeyboardWhenTappedAround()
        usernameFieldController = MDCTextInputControllerOutlined(textInput: usernameTextField)
        usernameFieldController?.activeColor = UIColor(named: "infomaniakTint")
        usernameFieldController?.inlinePlaceholderColor = UIColor(named: "outlineColor")
        usernameFieldController?.floatingPlaceholderNormalColor = UIColor(named: "outlineColor")
        usernameFieldController?.floatingPlaceholderActiveColor = UIColor(named: "infomaniakTint")
        usernameTextField.textColor = UIColor(named: "textColor")

        roomLinkFieldController = MDCTextInputControllerOutlined(textInput: roomLinkTextField)
        roomLinkFieldController?.activeColor = UIColor(named: "infomaniakTint")
        roomLinkFieldController?.inlinePlaceholderColor = UIColor(named: "outlineColor")
        roomLinkFieldController?.floatingPlaceholderNormalColor = UIColor(named: "outlineColor")
        roomLinkFieldController?.floatingPlaceholderActiveColor = UIColor(named: "infomaniakTint")
        roomLinkTextField.textColor = UIColor(named: "textColor")
        roomLinkTextField.trailingViewMode = .always

        let infoButton = UIButton(type: .custom)
        infoButton.setImage(UIImage(named: "ic_info"), for: .normal)
        infoButton.tintColor = UIColor(named: "outlineColor")!
        infoButton.addTarget(self, action: #selector(JoinViewController.infoButtonPressed), for: .touchUpInside)
        roomLinkTextField.trailingView = infoButton

        if username != nil {
            usernameTextField.text = username
        }

        if roomId == nil {
            roomId = generateRoomId()
        }
    }

    @objc func infoButtonPressed() {
        let alertController = UIAlertController(title: "", message: "copyLinkExplanation".localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    private func fillRoomLinkWithUrl(_ url: URL) {
        if let roomId = extractRoomIdFromUrl(url) {
            roomLinkTextField.text = url.absoluteString
            self.roomId = roomId
        }
    }

    private func extractRoomIdFromUrl(_ url: URL) -> String? {
        if url.absoluteString.starts(with: baseServerURL) || url.absoluteString.starts(with: "https://meet.infomaniak.com") {
            if let hash = URLComponents(url: url, resolvingAgainstBaseURL: true)?.path.replacingOccurrences(of: "/", with: "") {
                return hash.count > 0 ? hash : nil
            }
        } else if url.absoluteString.starts(with: "kmeet://") {
            if let hash = URLComponents(url: url, resolvingAgainstBaseURL: true)?.url?.absoluteString.replacingOccurrences(of: "kmeet://", with: "") {
                return hash.count > 0 ? hash : nil
            }
        }
        return nil
    }

    private func generateRoomId() -> String {
        return String((0..<16).map { _ in hashCharList.randomElement()! })
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if joining {
            return usernameTextField.text!.count > 1 && roomLinkTextField.text!.count > 0
        } else {
            return usernameTextField.text!.count > 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(JoinViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        if joining {
            if let url = joinUrl {
                fillRoomLinkWithUrl(url)
            } else if UIPasteboard.general.hasURLs {
                if let url = UIPasteboard.general.url {
                    fillRoomLinkWithUrl(url)
                }
            } else if UIPasteboard.general.hasStrings {
                if let possibleRoomLink = UIPasteboard.general.string {
                    if possibleRoomLink.count == 16 {
                        roomLinkTextField.text = possibleRoomLink
                        roomId = possibleRoomLink
                    } else if let url = URL(string: possibleRoomLink) {
                        fillRoomLinkWithUrl(url)
                    }
                }
            }
        } else {
            roomLinkTextField.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        roomLinkTextField.endEditing(true)
        usernameTextField.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let conferenceViewController = segue.destination as? ConferenceViewController {
            UserDefaults.store(username: usernameTextField.text!)
            conferenceViewController.roomName = (sender as? String ?? roomId)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            conferenceViewController.displayName = usernameTextField.text!
        }
    }

    @IBAction func joinMeetingButtonPressed(_ sender: UIButton) {
        if usernameTextField.text!.count < 2 {
            usernameFieldController?.setErrorText("mandatoryUserName".localized, errorAccessibilityValue: "mandatoryUserName".localized)
        }
        if roomLinkTextField.text!.count < 1 {
            roomLinkFieldController?.setErrorText("mandatoryField".localized, errorAccessibilityValue: "mandatoryField".localized)
        }
    }

    @IBAction func usenameChanged(_ sender: UITextField) {
        if usernameTextField.text!.count > 0 {
            usernameFieldController?.setErrorText(nil, errorAccessibilityValue: nil)
        }
    }

    @IBAction func roomIdChanged(_ sender: UITextField) {
        if roomLinkTextField.text!.count > 0 {
            roomLinkFieldController?.setErrorText(nil, errorAccessibilityValue: nil)
        }
        roomId = sender.text
    }

// MARK: - Keyboard management
    @objc func keyboardWillChange(notification: Notification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
                if (curFrame.origin.y > targetFrame.origin.y) {
                    self.topConstraint.constant = -targetFrame.height
                    self.centerConstraint.isActive = false
                    self.bottomConstraint.constant = targetFrame.height
                } else if curFrame.origin.y < targetFrame.origin.y {
                    self.topConstraint.constant = 16
                    self.centerConstraint.isActive = true
                    self.bottomConstraint.constant = 16
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
    }

    class func instantiate() -> JoinViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JoinViewController") as! JoinViewController
    }

}
