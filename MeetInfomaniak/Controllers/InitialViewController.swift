//
//  InitialViewController.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 05.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
        
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
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let joinViewController = segue.destination as? JoinViewController {
            joinViewController.joining = segue.identifier == "joinMeetingSegue"
        }
        
    }
    
    class func instantiate() -> InitialViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
    }

}
