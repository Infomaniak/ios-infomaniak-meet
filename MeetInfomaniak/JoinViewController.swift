//
//  ViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var roomNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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


}

