//
//  ExListVC.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD

protocol ContactViewShowDelegate {
    func showContactVC(_ mesageId: Int)
}

class ExListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ExTableView: UITableView!
    
    var exList = [JSON]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ExTableView.register(UINib(nibName: "ExTVCell", bundle: nil), forCellReuseIdentifier: "ExTVCellID")
        handleLoadExList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        ExTableView.delegate = self
        ExTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func handleLoadExList() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Instance.appDel.accessToken)"]
        AF.request(ApiConfig.exlist, method: .get, headers: headers).validate(contentType: ["application/json"]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let responseData = JSON(value)
                    self.exList = responseData.arrayValue
                    self.ExTableView.reloadData()
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    if response.response?.statusCode == 401 {
                        APICall.refreshToken() { resutlt in
                            if resutlt {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                self.handleLoadExList()
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
        return exList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExTVCellID", for: indexPath) as! ExTVCell
        cell.selectionStyle = .none
        cell.nameLabel.text = exList[indexPath.row]["name"].string
        cell.tag = exList[indexPath.row]["id"].int!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVCID") as! DetailVC
        detailVC.exItem = exList[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func onAddNew(_ sender: UIButton) {
        let selectCategoryVC = storyboard?.instantiateViewController(withIdentifier: "SelectCategoryVCID") as! SelectCategoryVC
        /*let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(selectCategoryVC, animated: false)*/
        selectCategoryVC.delegate = self
        self.navigationController?.present(selectCategoryVC, animated: true, completion: nil)
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

extension ExListVC : ContactViewShowDelegate {
    func showContactVC(_ mesageId: Int) {
        let selectContactVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectContactVC") as! SelectContactVC
        selectContactVC.selectedMessageId = mesageId
        self.navigationController?.pushViewController(selectContactVC, animated: false)
    }
}
