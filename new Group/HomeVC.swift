//
//  HomeVC.swift
//  iou-swift
//
//  Created by 李书康 on 2018/12/6.
//  Copyright © 2018 com.li.www. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var me: MeModel? {
        didSet {
            self.nickName.title = self.me?.userName ?? "默认名称"
        }
    }
    
    lazy var table: UITableView = {
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: Screen().width, height: Screen().height - Screen().status_nav_h))
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        table.tableFooterView = UIView()    //去掉多余分割线
        return table
    }()
    
    lazy var nickName: UIBarButtonItem = {
        let nickName = UIBarButtonItem.init()
        return nickName
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.table)
        self.navigationItem.rightBarButtonItem = self.nickName
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension HomeVC {
    
    private func loadData() {
        NetWorkRequest2(.getMe, completion: { (json) -> (Void) in
            
            self.me = codableFromJSON(json: json, codable: MeModel.self)
        }) { (error) -> (Void) in
            print(error)
        }
    }
    
    // MARK: 代理方法 - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var text: String = ""
        switch indexPath.row {
        case 0:
            text = "登录"
        case 1:
            text = "退出"
        case 2:
            text = "获取验证码"
        case 3:
            text = "个人信息"
        default:
            text = "----"
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Cell_Cancel_Select(tableView: table)
        
        switch indexPath.row {
        case 0:
            
            let alert = UIAlertController.init(title: "提示", message: "请输入验证码", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField { (textField) in
                textField.placeholder = "请输入手机号"
            }
            alert.addTextField { (textField) in
                textField.placeholder = "请输入验证码"
            }
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel) { (action) in
                print("取消")
            }
            let confirm = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default) { (action) in
                NetWorkRequest2(.loginMobile(mobile: alert.textFields?.first?.text ?? "", verificationCode: alert.textFields?.last?.text ?? "", imei: "10000"), completion: { (json) -> (Void) in
                    self.loadData()
                }, failure: { (message) -> (Void) in
                    
                })
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)
            
        case 1:
            setLocal(key: .token, value: "")
            self.me = codableFromJSON(json: "{}", codable: MeModel.self)

        case 2:
            let alert = UIAlertController.init(title: "提示", message: "请输入手机号码", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField { (textField) in
                textField.placeholder = "请输入手机号码"
            }
            let cancel = UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel) { (action) in
                print("取消")
            }
            let confirm = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default) { (action) in
                NetWorkRequest(.verificationCodeForLogin(mobile: alert.textFields?.first?.text ?? "", usageType: "SIGNIN_BY_MOBILE")) { (response) -> (Void) in
                    print(response)
                }
            }
            alert.addAction(cancel)
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)

        case 3:
            NetWorkRequest2(.getMe, completion: { (json) -> (Void) in
                print(json)
            }) { (error) -> (Void) in
                
            }
        default:
            break
        }
    }
    
}

struct MeModel : Codable {
    let account : Int?
    let avatarUrl : String?
    let haveNotice : Bool?
    let havePaid : Int?
    let havePwd : Bool?
    let haveReal : Bool?
    let mobile : Int?
    let needCollectAmount : Int?
    let needCollectAmountIn30Days : Int?
    let needCollectAmountIn7Days : Int?
    let needRepayAmount : Int?
    let needRepayAmountIn30Days : Int?
    let needRepayAmountIn7Days : Int?
    let userId : Int?
    let userName : String?
}



public func JSONFromData(data: Data) -> JSON? {
    return JSON(parseJSON: String(data: data, encoding: String.Encoding.utf8) ?? "{}")
}

public func dataFromJSON(json: JSON) -> Data? {
    if let data = try? json.rawData() { return data }
    return nil
}

public func codableFromData<T: Codable>(data: Data, codable: T.Type) -> T? {
    if let codable = try? JSONDecoder().decode(codable, from: data) { return codable }
    return nil
}

public func dataFromCodable<T: Codable>(codable: T) -> Data? {
    if let data = try? JSONEncoder().encode(codable) { return data }
    return nil
}

public func JSONFromCodable<T: Codable>(codable: T) -> JSON? {
    if let data = try? JSONEncoder().encode(codable) { return JSONFromData(data: data) }
    return nil
}

public func codableFromJSON<T: Codable>(json: JSON, codable: T.Type) -> T? {
    if let codable = try? JSONDecoder().decode(codable, from: json.rawData()) { return codable }
    return nil
}

// MARK: model层
