//
//  SettingsVC.swift
//  unmatch
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var signoutButton: UIButton! {
        didSet {
            signoutButton.layer.cornerRadius = 26
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onActionSignout(_ sender: UIButton) {
        Utils.showSignoutMessage(self)
    }
}
