//
//  SelectContactVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import UIKit
import Contacts
import CallKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import libPhoneNumber_iOS

class SelectContactVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedMessageId = 0
    var refreshControl: UIRefreshControl!
    var blockedNumbers: [String] = []
    var contactList: [ContactModel] = []
    
    var contact: ContactModel!
    var blockNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Checking for new phone contacts")
        self.refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.isEditing = true
        
        self.checkAuthorizationStatus()
        
        self.showMessage("Please select a contact to send a break up message too. We suggest blocking this contact before sending a breakup message.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func checkAuthorizationStatus() {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts) as CNAuthorizationStatus
        if status == CNAuthorizationStatus.denied || status == CNAuthorizationStatus.restricted {
            self.promptUserForContactAccess()
        } else {
            self.readContacts()
        }
    }
    
    func readContacts() {
        self.contactList = []
        self.tableView.reloadData()
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
            if granted == false {
                // request again
                self.promptUserForContactAccess()
            } else {
                //let predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactStore.defaultContainerIdentifier())
                var contacts: [CNContact]! = []
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, /*CNContactEmailAddressesKey,*/ CNContactThumbnailImageDataKey] as [Any]
                let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                do {
                    //contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    try contactStore.enumerateContacts(with: request) { (contact, stop) in
                        contacts.append(contact)
                    }
                    DispatchQueue.main.async {
                        if contacts.count == 0 {
                            self.showMessage("You have no contact in your phone.")
                        } else {
                            var tempContacts: [ContactModel] = []
                            for contact in contacts {
                                //if (contact.phoneNumbers).count > 0 {
                                    var tempArray: [String] = []
                                    for phoneNumber in contact.phoneNumbers {
                                        tempArray.append(phoneNumber.value.stringValue.removeFormat())
                                    }
                                    var contactModel = ContactModel(contact)
                                    contactModel.phoneNumbers = tempArray
                                    let blockedIds = self.getBlockedIds()
                                    if blockedIds.contains(contactModel.id) {
                                        contactModel.isBlocked = true
                                    }
                                    tempContacts.append(contactModel)
                                //}
                            }
                            self.contactList = tempContacts.sorted(by: { $0.givenName.lowercased() < $1.givenName.lowercased() })
                            print(self.contactList.count)
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        })
    }
    
    func updateBlockedIds(_ idList: [String]) {
        UserDefaults.standard.removeObject(forKey: "BLOCKED_IDS")
        UserDefaults.standard.set(idList, forKey: "BLOCKED_IDS")
        UserDefaults.standard.synchronize()
    }
    
    func getBlockedIds() -> [String]  {
        return UserDefaults.standard.value(forKey: "BLOCKED_IDS") as? [String] ?? []
    }
    
    func updateBlockedPhoneNumbers(_ phoneNumbers: [String]) {
        let defaults = UserDefaults(suiteName: "group.com.mateo.unmatch")
        defaults?.removeObject(forKey: "blockList")
        defaults?.set(phoneNumbers, forKey: "blockList")
        defaults?.synchronize()
    }
    
    func getBlockedContacts() -> [String] {
        let defaults = UserDefaults(suiteName: "group.com.mateo.unmatch")
        let blockedContacts = defaults?.value(forKey: "blockList") ?? []
        return blockedContacts as! [String]
    }
    
    func promptUserForContactAccess() {
        let alert = UIAlertController(title: "Access to contacts.", message: "This app requires access to contacts", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(NSURL.init(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        alert.addAction(settingsAction)
        self.present(alert, animated: true)
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    // MARK: - User defined methods
    
    @objc func refreshData(_ sender: Any) {
        self.checkAuthorizationStatus()
    }
    
    func syncBlockList() {
        //save blocklist in userdefaults
        self.updateBlockedPhoneNumbers(self.blockedNumbers)
        //reload extension to update blocklist entries
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.mateo.unmatch.CallBlocker", completionHandler: nil)
    }
    
    /* Function to sort the blocklist array by numerically ascending */
    func sortArray(arrayToSort: [String])->[String] {
        let sortedArray = arrayToSort.sorted(by:) { (first, second) in
            first.compare(second, options: .numeric) == ComparisonResult.orderedAscending
        }
        print(sortedArray)
        return sortedArray
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let nameLabel = cell.textLabel!
        let contact = self.contactList[indexPath.row]
        let attributedString = NSMutableAttributedString(string: contact.givenName + " " + contact.familyName)
        let boldFont = UIFont.boldSystemFont(ofSize: nameLabel.font.pointSize)
        let range = (attributedString.string as NSString).range(of: contact.familyName)
        attributedString.addAttribute(.font, value: boldFont, range: range)
        nameLabel.attributedText = attributedString
        
        //cell.isUserInteractionEnabled = !contact.isBlocked
//        if contact.isBlocked {
//            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to send a breakup message to this contact?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.contact = self.contactList[indexPath.row]
            if self.contact.phoneNumbers.count == 0 {
                self.showMessage("This contact doesn't contain any phone number.")
                return
            }
            var blockedIds: [String] = []
            if !self.contact.isBlocked {
                blockedIds.append(self.contact.id)
                self.blockedNumbers.append(contentsOf: self.contact.phoneNumbers)
                
                self.updateBlockedIds(blockedIds)
                
                self.blockedNumbers = self.blockedNumbers.sorted()
                self.syncBlockList()
            }
            
            guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
                return
            }
            do {
                let phoneNumber: NBPhoneNumber = try phoneUtil.parse(self.contact.phoneNumbers[0], defaultRegion: "US")
                self.blockNumber = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
            self.sendContact()
        })
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }

    func sendContact() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Instance.appDel.accessToken)", "Content-Type": "application/json"]
        let params: Parameters = ["name": self.contact.givenName + " " + self.contact.familyName, "phoneNumber": self.blockNumber, "breakupMessageId": self.selectedMessageId]
        //let params: Parameters = ["name": "Test Number", "phoneNumber": "+16479880124", "breakupMessageId": self.selectedMessageId]
        AF.request(ApiConfig.exlist, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString { response in
            
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                MBProgressHUD.hide(for: self.view, animated: true)
                let successVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessVCID") as! SuccessVC
                //self.navigationController?.pushViewController(successVC, animated: true)
                guard let navigationController = self.navigationController else { return }
                var navigationArray = navigationController.viewControllers
                navigationArray.removeLast()
                navigationArray.append(successVC)
                navigationController.setViewControllers(navigationArray, animated: true)
            } else if statusCode == 401 {
                APICall.refreshToken() { resutlt in
                    if resutlt {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.sendContact()
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        Utils.showMessage(self, "Seems your token expired. Please login again", {_ in
                            Utils.signOut()
                        })
                    }
                }
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                var message = "Something went wrong. Please try again."
                if let data = response.data, let responseMessage = String(data: data, encoding: .utf8) {
                    message = responseMessage
                }
                self.showMessage(message)
            }
        }
    }
}

extension String {
    func removeFormat() -> String {
        var mobileNumber: String = self
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.symbols)
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        mobileNumber = mobileNumber.trimmingCharacters(in: CharacterSet.controlCharacters)
        mobileNumber = mobileNumber.replacingOccurrences(of: "+", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: " ", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "-", with: "")
        mobileNumber = mobileNumber.replacingOccurrences(of: "\u{00a0}", with: "")
        return mobileNumber
    }
}
