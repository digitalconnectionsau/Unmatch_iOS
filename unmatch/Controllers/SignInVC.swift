//
//  SignInVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/1.
//

import UIKit
import Alamofire
import MBProgressHUD
import SwiftyJSON

class SignInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            self.emailTextField.layer.masksToBounds = true
            self.emailTextField.layer.borderWidth = 1
            self.emailTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            self.emailTextField.layer.cornerRadius = 26
            self.emailTextField.setHorizontalPaddingPoints(16)
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            self.passwordTextField.layer.masksToBounds = true
            self.passwordTextField.layer.borderWidth = 1
            self.passwordTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            self.passwordTextField.layer.cornerRadius = 26
            self.passwordTextField.setHorizontalPaddingPoints(16)
        }
    }
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.layer.cornerRadius = 26
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        //self.emailTextField.text = "test@test.com"
        //self.passwordTextField.text = "Testtest"
        //self.emailTextField.text = "aaa@test.com"
        //self.passwordTextField.text = "Glowglow"
        
        if let email = UserDefaults.retrieveObject("USER_EMAIL") as? String {
            self.emailTextField.text = email
        }
        
        if let password = UserDefaults.retrieveObject("USER_PASSWORD") as? String {
            self.passwordTextField.text = password
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.view.endEditing(true)
            self.onSignIn(nil)
        }
        return true
    }
    
    func handleSignIn(_ email: String, password: String) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let params: Parameters = ["email": email, "password": password]
        AF.request(ApiConfig.signin, method: .post, parameters: params, encoding: JSONEncoding.default).validate(contentType: ["application/json"]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let responseData = JSON(value)
                    if !responseData["isAuthSuccessful"].boolValue {
                        Utils.showMessage(self, responseData["errorMessage"].string ?? "Login Failed. Please try again")
                    } else {
                        Instance.appDel.setAuthData(accessToken: responseData["accessToken"].stringValue, refreshToken: responseData["refreshToken"].stringValue)
                        
                        UserDefaults.saveObject(email, key: "USER_EMAIL")
                        UserDefaults.saveObject(password, key: "USER_PASSWORD")
                        
                        let startedVC = self.storyboard?.instantiateViewController(withIdentifier: "StartedVCID") as! StartedVC
                        self.navigationController?.pushViewController(startedVC, animated: true)
                    }
                case .failure(let error):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print(error.localizedDescription)
                    Utils.showMessage(self, "Login Failed. Something went wrong.")
            }
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onSignIn(_ sender: UIButton?) {
        self.view.endEditing(true)
        let email = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.passwordTextField.text!
        
        if !Utils.isValidEmail(email) {
            Utils.showMessage(self, "Please input vaild Email.")
        } else if password.count == 0 {
            Utils.showMessage(self, "Please input vaild Password.")
        } else {
            self.handleSignIn(email, password: password)
        }
    }
    
    @IBAction func handleBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func securePasswordButtonClicked(_ sender: Any) {
        if let sectureButton = sender as? UIButton {
            sectureButton.isSelected = !sectureButton.isSelected
            self.passwordTextField.isSecureTextEntry = !sectureButton.isSelected
        }
    }
}
