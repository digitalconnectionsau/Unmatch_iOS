//
//  API.swift
//  webservicesDemo
//
//  Created by Ahmed Elzohry on 1/31/17.
//  Copyright © 2017 Ahmed Elzohry. All rights reserved.
//

import UIKit
import Alamofire
//import SVProgressHUD
import SwiftyJSON

class APICall: NSObject {
    /*class func showHUD () {
        //SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.show()
    }
    
    class func showHUD(_ message: String) {
        SVProgressHUD.showInfo(withStatus: message)
        SVProgressHUD.dismiss(withDelay: 2)
    }
    
    class func hideHUD() {
        SVProgressHUD.dismiss()
    }
    
    class func hideHUD(_ success: Bool, _ delay: TimeInterval = 2) {
        if success {
            SVProgressHUD.showSuccess(withStatus: "Success!")
        } else {
            SVProgressHUD.showError(withStatus: "Failed!")
        }
        SVProgressHUD.dismiss(withDelay: delay)
    }*/
    
    class func afterDelay(_ delay: Double, _ closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    class func refreshToken(completion: @escaping (_ result: Bool) -> Void) {
        
        let parameters = [
            "accessToken": Instance.appDel.accessToken,
            "refreshToken": Instance.appDel.refreshToken
            ] as [String : Any]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Instance.appDel.accessToken)"]
        AF.request(ApiConfig.refreshToken, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    completion(false)
                    break
                case .success(let value):
                    let responseData = JSON(value)
                    if !responseData["isAuthSuccessful"].boolValue {
                        completion(false)
                    } else {
                        Instance.appDel.setAuthData(accessToken: responseData["accessToken"].stringValue, refreshToken: responseData["refreshToken"].stringValue)
                        completion(true)
                    }
                    break
                }
        }
    }
}
