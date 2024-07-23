//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import MaterialComponents.MaterialTextFields
import UIKit

class JoinViewController: UIViewController {
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: MDCTextField!
    @IBOutlet weak var roomLinkTextField: MDCTextField!
    @IBOutlet weak var joinMeetingButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    private var usernameFieldController: MDCTextInputControllerOutlined!
    private var roomLinkFieldController: MDCTextInputControllerOutlined!
    private var infoButton: UIButton!

    private let roomCodeRegex = try! NSRegularExpression(pattern: #"^(\d{3}-\d{4}-\d{3}|\d{10})$"#)
    private let hashCharList = Array("abcdefghijklmnopqrstuvwxyz")
    private var roomId: String!
    private var host: URL?
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
        navigationController?.navigationBar.tintColor = Assets.infomaniakTintColor

        hideKeyboardWhenTappedAround()
        usernameFieldController = MDCTextInputControllerOutlined(textInput: usernameTextField)
        applyThemeTo(inputController: usernameFieldController!)

        roomLinkFieldController = MDCTextInputControllerOutlined(textInput: roomLinkTextField)
        applyThemeTo(inputController: roomLinkFieldController!)

        roomLinkTextField.trailingViewMode = .always

        infoButton = UIButton(type: .custom)
        infoButton.setImage(Assets.infoIcon, for: .normal)
        infoButton.tintColor = Assets.outlineColor
        infoButton.addTarget(self, action: #selector(JoinViewController.infoButtonPressed), for: .touchUpInside)
        roomLinkTextField.trailingView = infoButton

        if username != nil {
            usernameTextField.text = username
        }

        if roomId == nil {
            roomId = generateRoomId()
        }
    }

    private func applyThemeTo(inputController: MDCTextInputControllerOutlined) {
        inputController.activeColor = Assets.infomaniakTintColor
        inputController.inlinePlaceholderColor = Assets.outlineColor
        inputController.floatingPlaceholderNormalColor = Assets.outlineColor
        inputController.floatingPlaceholderActiveColor = Assets.infomaniakTintColor
        inputController.textInput!.textColor = Assets.textColor
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func infoButtonPressed(error: Bool) {
        showAlert(title: "", message: "copyLinkExplanation".localized)
    }

    @objc func infoErrorButtonPressed() {
        showAlert(title: "", message: "codeDoesntExistError".localized)
    }

    private func fillRoomLinkWithUrl(_ url: URL) {
        if let result = extractHostAndRoomIdFromUrl(url) {
            roomLinkTextField.text = url.absoluteString
            host = result.0
            roomId = result.1
        }
    }

    private func extractHostAndRoomIdFromUrl(_ url: URL) -> (URL, String)? {
        if let scheme = url.scheme,
           url.lastPathComponent.count > 0 {
            let hash = url.lastPathComponent

            if scheme == "kmeet" {
                return extractHostAndRoomIdFromUrl(URL(string: url.absoluteString.replacingOccurrences(
                    of: "kmeet://",
                    with: "https://"
                ))!)
            } else if let host = url.host,
                      scheme == "https" {
                return (URL(string: scheme + "://" + host)!, hash)
            }
        }
        return nil
    }

    private func generateRoomId() -> String {
        return String((0 ..< 16).map { _ in hashCharList.randomElement()! })
    }

    func canStartMeeting() -> Bool {
        if joining {
            return usernameTextField.text!.count > 1 && roomLinkTextField.text!.count > 0
        } else {
            return usernameTextField.text!.count > 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(JoinViewController.keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        if joining {
            if let url = joinUrl {
                fillRoomLinkWithUrl(url)
            } else if UIPasteboard.general.hasURLs {
                if let url = UIPasteboard.general.url {
                    fillRoomLinkWithUrl(url)
                }
            } else if UIPasteboard.general.hasStrings {
                if let possibleRoomLink = UIPasteboard.general.string {
                    if possibleRoomLink.count == 16 || roomCodeRegex.matches(
                        in: possibleRoomLink,
                        options: [],
                        range: NSRange(location: 0, length: possibleRoomLink.utf16.count)
                    ).count > 0 {
                        roomLinkTextField.text = possibleRoomLink
                        roomId = possibleRoomLink
                    } else if let url = URL(string: possibleRoomLink) {
                        fillRoomLinkWithUrl(url)
                    }
                }
            }

            // If user already has a username in the link, he is probably coming from kChat, directly join
            if var urlComponents = URLComponents(string: roomLinkTextField.text ?? ""),
               let username = urlComponents.queryItems?.first(where: { $0.name == "username" })?.value,
               !username.isEmpty {
                // Remove username from current link to prevent join loop
                urlComponents.queryItems = nil
                joinUrl = urlComponents.url!

                usernameTextField.text = username
                goToConferenceViewController()
            }

        } else {
            joinMeetingButton.setTitle("createButton".localized, for: .normal)
            joinMeetingButton.setTitle("createButton".localized, for: .disabled)
            titleLabel.text = "titleCreate".localized
            roomLinkTextField.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomLinkTextField.endEditing(true)
        usernameTextField.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func goToConferenceViewController() {
        guard let username = usernameTextField.text else { return }

        UserDefaults.store(username: username)
        let conferenceViewController = ConferenceViewController(
            displayName: username,
            roomName: roomId,
            host: host
        )
        navigationController?.pushViewController(conferenceViewController, animated: true)
    }

    @IBAction func joinMeetingButtonPressed(_ sender: UIButton) {
        joinMeetingButton.setLoading(true)
        if usernameTextField.text!.count < 2 {
            usernameFieldController?.setErrorText(
                "mandatoryUserName".localized,
                errorAccessibilityValue: "mandatoryUserName".localized
            )
        }

        let roomText = roomLinkTextField.text!
        if roomText.count < 1 {
            roomLinkFieldController?.setErrorText("mandatoryField".localized, errorAccessibilityValue: "mandatoryField".localized)
        }

        if canStartMeeting() {
            if roomCodeRegex.matches(in: roomText, options: [], range: NSRange(location: 0, length: roomText.utf16.count))
                .count > 0 {
                ApiFetcher.getRoomNameFromCode(roomText.replacingOccurrences(of: "-", with: "")) { response, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            self.roomLinkFieldController?.setErrorText(
                                "",
                                errorAccessibilityValue: "codeDoesntExistError".localized
                            )
                            self.infoButton.tintColor = self.roomLinkFieldController?.errorColor
                            self.infoButton.removeTarget(self, action: nil, for: .touchUpInside)
                            self.infoButton.addTarget(
                                self,
                                action: #selector(JoinViewController.infoErrorButtonPressed),
                                for: .touchUpInside
                            )
                        } else {
                            self.roomId = response?.data.name
                            if let host = response?.data.hostname {
                                self.host = URL(string: "https://" + host)
                            } else {
                                self.host = URL(string: baseServerURL)!
                            }
                            self.goToConferenceViewController()
                        }
                        self.joinMeetingButton.setLoading(false)
                    }
                }
            } else {
                joinMeetingButton.setLoading(false)
                goToConferenceViewController()
            }
        } else {
            joinMeetingButton.setLoading(false)
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

        infoButton.tintColor = Assets.outlineColor
        infoButton.removeTarget(self, action: nil, for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(JoinViewController.infoButtonPressed), for: .touchUpInside)

        if let possibleUrl = sender.text,
           URL(string: possibleUrl) != nil {
            roomId = sender.text
        } else {
            roomId = sender.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }
    }

    // MARK: - Keyboard management

    @objc func keyboardWillChange(notification: Notification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0.0,
            options: UIView.KeyframeAnimationOptions(rawValue: curve),
            animations: {
                if curFrame.origin.y > targetFrame.origin.y {
                    self.topConstraint.constant = -targetFrame.height
                    self.centerConstraint.isActive = false
                    self.bottomConstraint.constant = targetFrame.height
                } else if curFrame.origin.y < targetFrame.origin.y {
                    self.topConstraint.constant = 16
                    self.centerConstraint.isActive = true
                    self.bottomConstraint.constant = 16
                }
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    class func instantiate() -> JoinViewController {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "JoinViewController") as! JoinViewController
    }
}
