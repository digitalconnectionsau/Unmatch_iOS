//
//  ContactModel.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/12.
//

import Foundation
import Contacts

struct ContactModel {
    var id = ""
    var givenName = ""
    var familyName = ""
    var phoneNumbers: [String] = []
    var isBlocked = false
    
    init(_ contact: CNContact) {
        self.id = contact.identifier
        self.givenName = contact.givenName
        self.familyName = contact.familyName
    }
}
