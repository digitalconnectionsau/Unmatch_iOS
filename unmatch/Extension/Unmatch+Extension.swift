//
//  Unmatch+Extension.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import Foundation

func isValidEmail(emailStr: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: emailStr)
}
