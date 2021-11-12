//
//  DetailVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/13.
//

import UIKit
import SwiftyJSON
import Alamofire
import MBProgressHUD

class DetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var exItem: JSON = [:]
    var messageList = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.register(UINib(nibName: "MessageTVCell", bundle: nil), forCellReuseIdentifier: "MessageTVCellID")
        
        self.getMessages()
    }
    
    func getMessages() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Instance.appDel.accessToken)"]
        AF.request(ApiConfig.getMessages + "\(exItem["id"].int!)", method: .get, encoding: URLEncoding.default, headers: headers).validate(contentType: ["application/json"]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let responseData = JSON(value)
                    self.messageList = responseData.arrayValue
                    self.nameLabel.text = self.exItem["name"].string!
                    self.tableView.reloadData()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    if response.response?.statusCode == 401 {
                        APICall.refreshToken() { resutlt in
                            if resutlt {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.getMessages()
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
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTVCellID") as! MessageTVCell
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.messageText.text = messageList[indexPath.row]["messageBody"].string!
        return cell
    }
    
    @IBAction func handleBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
