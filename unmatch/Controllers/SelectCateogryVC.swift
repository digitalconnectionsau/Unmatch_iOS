//
//  SelectTypeVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

class SelectCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var categoryList = [JSON]()
    var selectedRow = [Int: Int]()
    var selectedMessage: JSON = [:]
    var isSelected = false
    var delegate: ContactViewShowDelegate?
    
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 26
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageView: UIView! {
        didSet {
            messageView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.register(UINib(nibName: "CategoryTVCell", bundle: nil), forCellReuseIdentifier: "CategoryTVCellID")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.getExesList()
        
    }
    
    func getExesList() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Instance.appDel.accessToken)"]
        AF.request(ApiConfig.questions, method: .get, encoding: URLEncoding.default, headers: headers).validate(contentType: ["application/json"]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let responseData = JSON(value)
                    self.categoryList = responseData.arrayValue
                    self.tableView.reloadData()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    if response.response?.statusCode == 401 {
                        APICall.refreshToken() { resutlt in
                            if resutlt {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.getExesList()
                            } else {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                Utils.showMessage(self, "Seems your token expired. Please login again", {_ in
                                    Utils.signOut()
                                })
                            }
                        }
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        Utils.showMessage(self, "Something went wrong. Please try again")
                    }
                    break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTVCellID", for: indexPath) as! CategoryTVCell
        cell.selectionStyle = .none
        cell.categoryLabel?.text = categoryList[indexPath.row]["category"].stringValue
        if let val = selectedRow[indexPath.section] {
            if indexPath.row == val {
                cell.contentView.layer.borderColor = UIColor(red: 1, green: 85 / 255, blue: 85 / 255, alpha: 1).cgColor
                cell.contentView.backgroundColor = UIColor(red: 1, green: 85 / 255, blue: 85 / 255, alpha: 1)
                cell.categoryLabel?.textColor = .white
            } else {
                cell.contentView.layer.borderColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1).cgColor
                cell.contentView.backgroundColor = .white
                cell.categoryLabel?.textColor = .black
            }
        } else {
            cell.contentView.layer.borderColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1).cgColor
            cell.contentView.backgroundColor = .white
            cell.categoryLabel?.textColor = .black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMessage = categoryList[indexPath.row]["breakupMessageDTOs"][0]
        //self.titleLabel.text = selectedMessage["message"].stringValue
        selectedRow.removeAll()
        selectedRow.updateValue(indexPath.row, forKey: indexPath.section)
        tableView.reloadData()
    }
    
    @IBAction func handleNext(_ sender: UIButton) {
        if !isSelected {
            titleLabel.text = "Preview breakup message."
            tableView.isHidden = true
            messageView.isHidden = false
            messageLabel.text = selectedMessage["message"].stringValue
            nextButton.setTitle("SELECT CONTACT", for: .normal)
            isSelected = true
        } else {
            //let selectContactVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectContactVC") as! SelectContactVC
            //selectContactVC.selectedMessageId = selectedMessage["messageId"].intValue
            //self.navigationController?.pushViewController(selectContactVC, animated: true)
            self.dismiss(animated: true, completion: nil)
            self.delegate?.showContactVC(selectedMessage["messageId"].intValue)
        }
    }
    
    @IBAction func handleBack(_ sender: UIButton) {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
