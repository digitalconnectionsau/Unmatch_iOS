//
//  LandingVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/1.
//

import UIKit

class LandingVC: UIViewController {
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        createButton.layer.cornerRadius = 26
        
        signInButton.layer.borderWidth = 3
        signInButton.layer.borderColor = UIColor(red: 255, green: 85/255, blue: 85/255, alpha: 1).cgColor
        signInButton.layer.cornerRadius = 26
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCreate(_ sender: UIButton) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpVCID") as! SignUpVC
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func onSignIn(_ sender: UIButton) {
        let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInVCID") as! SignInVC
        self.navigationController?.pushViewController(signInVC, animated: true)
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
