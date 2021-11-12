//
//  SignUpVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/1.
//

import UIKit
import Alamofire
import MBProgressHUD
import DatePickerDialog
import SwiftyJSON

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.layer.masksToBounds = true
            nameTextField.layer.borderWidth = 1
            nameTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            nameTextField.layer.cornerRadius = 26
            nameTextField.setHorizontalPaddingPoints(16)
        }
    }
    @IBOutlet weak var dobTextField: UITextField! {
        didSet {
            dobTextField.layer.masksToBounds = true
            dobTextField.layer.borderWidth = 1
            dobTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            dobTextField.layer.cornerRadius = 26
            dobTextField.setHorizontalPaddingPoints(16)
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.layer.masksToBounds = true
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            emailTextField.layer.cornerRadius = 26
            emailTextField.setHorizontalPaddingPoints(16)
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.masksToBounds = true
            passwordTextField.layer.borderWidth = 1
            passwordTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            passwordTextField.layer.cornerRadius = 26
            passwordTextField.setHorizontalPaddingPoints(16)
        }
    }
    @IBOutlet weak var confirmTextField: UITextField! {
        didSet {
            confirmTextField.layer.masksToBounds = true
            confirmTextField.layer.borderWidth = 1
            confirmTextField.layer.borderColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1).cgColor
            confirmTextField.layer.cornerRadius = 26
            confirmTextField.setHorizontalPaddingPoints(16)
        }
    }
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.layer.cornerRadius = 26
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmTextField.becomeFirstResponder()
        } else if textField == confirmTextField {
            self.view.endEditing(true)
            self.handleSignUp()
        }
        return true
    }
    
    func handleSignUp() {
        if nameTextField.text!.isEmpty {
            nameTextField.becomeFirstResponder()
            return
        }
        if dobTextField.text!.isEmpty {
            DatePickerDialog().show("Date of Birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) { date in
                if let dt = date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    self.dobTextField.text = formatter.string(from: dt)
                }
            }
            return
        }
        if emailTextField.text!.isEmpty {
            emailTextField.becomeFirstResponder()
            return
        } else if !isValidEmail(emailStr: emailTextField.text!) {
            emailTextField.becomeFirstResponder()
            return
        }
        if passwordTextField.text!.isEmpty {
            passwordTextField.becomeFirstResponder()
            return
        }
        if confirmTextField.text!.isEmpty {
            confirmTextField.becomeFirstResponder()
            return
        }
        if passwordTextField.text! != confirmTextField.text! {
            confirmTextField.becomeFirstResponder()
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dob = dateFormatter.date(from:dobTextField.text!)!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dobString = dateFormatter.string(from: dob)
        let params: [String: String] = ["name": nameTextField.text!, "email": emailTextField.text!, "password": passwordTextField.text!, "confirmPassword": confirmTextField.text!, "dateOfBirth": dobString]
        AF.request(ApiConfig.signup, method: .post, parameters: params, encoding: JSONEncoding.default).validate(contentType: ["application/json"]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let responseData = JSON(value)
                    print(responseData)
                    if !responseData["isSuccessfulRegistration"].boolValue {
                        Utils.showMessage(self, responseData["errors"].arrayValue[0].string ?? "Register Failed. Please try again")
                    } else {
                        let signInVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInVCID") as! SignInVC
                        //self.navigationController?.pushViewController(signInVC, animated: true)
                        guard let navigationController = self.navigationController else { return }
                        var navigationArray = navigationController.viewControllers
                        navigationArray.removeLast()
                        navigationArray.append(signInVC)
                        navigationController.setViewControllers(navigationArray, animated: true)
                    }
                    
                case .failure(_):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    Utils.showMessage(self, "Register Failed. Please try again")
                    return
            }
        }
    }
    
    @IBAction func handleToggleDatePicker(_ sender: UIButton) {
        DatePickerDialog().show("Date of Birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) { date in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                self.dobTextField.text = formatter.string(from: dt)
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        self.handleSignUp()
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
    
    @IBAction func secureConfirmButtonClicked(_ sender: Any) {
        if let sectureButton = sender as? UIButton {
            sectureButton.isSelected = !sectureButton.isSelected
            self.confirmTextField.isSecureTextEntry = !sectureButton.isSelected
        }
    }
}

extension UITextField {
    func setHorizontalPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.rightView = paddingView
        self.leftViewMode = .always
        self.rightViewMode = .always
    }
}
