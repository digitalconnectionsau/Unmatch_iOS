//
//  StartedVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import UIKit

class StartedVC: UIViewController {

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
        UIView.transition(with: window, duration: 1.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
