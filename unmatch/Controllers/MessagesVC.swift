//
//  MessagesVC.swift
//  unmatch
//

import UIKit

class MessagesVC: UIViewController {

    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.layer.cornerRadius = 26
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onStart(_ sender: UIButton) {
        let mainTab = self.storyboard?.instantiateViewController(withIdentifier: "TabVCID") as! UITabBarController
        //self.navigationController?.pushViewController(mainTab, animated: true)
        
        guard let window = Instance.appDel.window else {
            return
        }
        window.rootViewController = mainTab
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 1, options: .transitionFlipFromLeft, animations: {}, completion: nil)
    }
}
