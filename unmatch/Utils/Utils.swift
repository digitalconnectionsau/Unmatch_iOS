//
//  Utils.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import Foundation
import UIKit

struct Instance {
    static let appDel =  UIApplication.shared.delegate as! AppDelegate
}

struct ApiConfig {
    
    static let serverUrl: String = "https://api.unmatchapp.com/api/"
    
    //MARK:>>>>>> endpoints
    //Authentication
    static let signin: String = serverUrl + "Authentication/Login"
    static let signup: String = serverUrl + "Authentication/Registration"
    static let exlist: String = serverUrl + "Exes"
    static let questions: String = serverUrl + "Message/BreakupMessages"
    static let getMessages: String = serverUrl + "Message/"
    
    static let refreshToken: String = serverUrl + "Token/RefreshToken"
}

class Utils {
    class func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    class func showMessage(_ viewController: UIViewController, _ message: String, _ handler: ((_ action:UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: handler)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }
    
    class func showSignoutMessage(_ viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Sign Out", style: .destructive, handler: {_ in
            Utils.signOut()
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }
    
    class func signOut() {
        //UserDefaults.removeObject("USER_EMAIL")
        //UserDefaults.removeObject("USER_PASSWORD")
        Instance.appDel.deleteAuthData()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LandingNavVC")
        
        guard let window = Instance.appDel.window else {
            return
        }
        window.rootViewController = controller
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 1, options: .transitionFlipFromRight, animations: {}, completion: nil)
    }
}

extension UserDefaults {
    class func saveObject(_ object: Any, key: String) {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func retrieveObject(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    class func retrieveString(_ key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    class func removeObject(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}
