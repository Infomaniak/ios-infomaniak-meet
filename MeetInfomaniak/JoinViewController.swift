//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var roomNameTextField: UITextField!
    var hashRoom = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        roomNameTextField.text = hashRoom
        
        fieldsView.layer.cornerRadius = 10
        fieldsView.layer.shadowColor = UIColor.black.cgColor
        fieldsView.layer.shadowOpacity = 0.25
        fieldsView.layer.shadowOffset = .zero
        fieldsView.layer.shadowRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(JoinViewController.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return roomNameTextField.text != nil && roomNameTextField.text!.count > 0 && userNameTextField.text != nil && userNameTextField.text!.count > 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let conferenceViewController = segue.destination as? ConferenceViewController {
            conferenceViewController.displayName = userNameTextField.text!
            conferenceViewController.roomName = roomNameTextField.text!
        }
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JoinViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
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
