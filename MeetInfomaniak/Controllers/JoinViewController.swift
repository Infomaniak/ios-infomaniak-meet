//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var roomLinkTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var roomLinkErrorLabel: UILabel!
    @IBOutlet weak var joinMeetingButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    private var infoButton: UIButton!

    private let roomCodeChecker = RoomCodeChecker()
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
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        configure(textField: usernameTextField)
        configure(textField: roomLinkTextField)

        infoButton = UIButton(type: .custom)
        infoButton.frame = CGRect(x: 0, y: 0, width: 44, height: 48)
        infoButton.setImage(Assets.infoIcon, for: .normal)
        infoButton.tintColor = Assets.outlineColor
        infoButton.addTarget(self, action: #selector(JoinViewController.infoButtonPressed), for: .touchUpInside)

        let infoButtonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 48))
        infoButtonContainer.addSubview(infoButton)
        roomLinkTextField.rightView = infoButtonContainer
        roomLinkTextField.rightViewMode = .always

        if username != nil {
            usernameTextField.text = username
        }

        if roomId == nil {
            roomId = generateRoomId()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let availableTitleWidth = titleLabel.bounds.width
        guard titleLabel.preferredMaxLayoutWidth != availableTitleWidth else { return }

        titleLabel.preferredMaxLayoutWidth = availableTitleWidth
        titleLabel.invalidateIntrinsicContentSize()
    }

    private func configure(textField: UITextField) {
        textField.borderStyle = .none
        textField.layer.borderColor = Assets.outlineColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftViewMode = .always
        textField.textColor = Assets.textColor
        textField.tintColor = Assets.infomaniakTintColor
        textField.delegate = self
    }

    private func setError(
        _ errorText: String?,
        accessibilityValue: String? = nil,
        on textField: UITextField,
        errorLabel: UILabel
    ) {
        let accessibilityError = accessibilityValue ?? errorText
        errorLabel.text = errorText
        errorLabel.isHidden = errorText?.isEmpty ?? true
        textField.accessibilityHint = accessibilityError
        if accessibilityError != nil {
            textField.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            textField.layer.borderColor = textField.isFirstResponder
                ? Assets.infomaniakTintColor.cgColor
                : Assets.outlineColor.cgColor
        }
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func infoButtonPressed() {
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
        return String((0 ..< 16).compactMap { _ in hashCharList.randomElement() })
    }

    func canStartMeeting() -> Bool {
        guard let username = usernameTextField.text else { return false }

        if joining {
            return username.count > 1 && (roomLinkTextField.text?.count ?? 0) > 0
        } else {
            return username.count > 1
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
                    if possibleRoomLink.count == 16 || roomCodeChecker.isRoomCode(text: possibleRoomLink) {
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
            setError(
                "mandatoryUserName".localized,
                on: usernameTextField,
                errorLabel: usernameErrorLabel
            )
        }

        let roomText = roomLinkTextField.text!
        if joining && roomText.isEmpty {
            setError(
                "mandatoryField".localized,
                on: roomLinkTextField,
                errorLabel: roomLinkErrorLabel
            )
        }

        guard canStartMeeting() else {
            joinMeetingButton.setLoading(false)
            return
        }

        if roomCodeChecker.isRoomCode(text: roomText) {
            ApiFetcher.getRoomNameFromCode(roomText.replacingOccurrences(of: "-", with: "")) { response, error in
                DispatchQueue.main.async {
                    guard error != nil else {
                        self.roomId = response?.data.name
                        if let host = response?.data.hostname {
                            self.host = URL(string: "https://" + host)
                        } else {
                            self.host = URL(string: baseServerURL)!
                        }
                        self.goToConferenceViewController()
                        self.joinMeetingButton.setLoading(false)
                        return
                    }

                    self.setError(
                        nil,
                        accessibilityValue: "codeDoesntExistError".localized,
                        on: self.roomLinkTextField,
                        errorLabel: self.roomLinkErrorLabel
                    )
                    self.infoButton.tintColor = .systemRed
                    self.infoButton.removeTarget(self, action: nil, for: .touchUpInside)
                    self.infoButton.addTarget(
                        self,
                        action: #selector(JoinViewController.infoErrorButtonPressed),
                        for: .touchUpInside
                    )
                    self.joinMeetingButton.setLoading(false)
                }
            }
        } else {
            if let rawLink = roomLinkTextField.text,
               let link = URL(string: rawLink),
               let scheme = link.scheme,
               let host = link.host {
                self.host = URL(string: "https://\(host)")
                roomId = rawLink.replacingOccurrences(of: "\(scheme)://\(host)/", with: "")
            }
            joinMeetingButton.setLoading(false)
            goToConferenceViewController()
        }
    }

    @IBAction func usenameChanged(_ sender: UITextField) {
        if usernameTextField.text!.count > 0 {
            setError(nil, on: usernameTextField, errorLabel: usernameErrorLabel)
        }
    }

    @IBAction func roomIdChanged(_ sender: UITextField) {
        if roomLinkTextField.text!.count > 0 {
            setError(nil, on: roomLinkTextField, errorLabel: roomLinkErrorLabel)
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

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.accessibilityHint == nil {
            textField.layer.borderColor = Assets.infomaniakTintColor.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.accessibilityHint == nil {
            textField.layer.borderColor = Assets.outlineColor.cgColor
        }
    }

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
