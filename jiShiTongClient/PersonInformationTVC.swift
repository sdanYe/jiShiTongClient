//
//  PersonInformationTVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 个人信息 ViewController
*/

class PersonInformationTVC: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    var user: User? {
        didSet {
            imageView.image = user?.portrait
            nicknameLabel.text = user?.nickname
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //
    /* 保持及时刷新信息
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 给 user 赋值， 放在这里可以及时刷新用户信息，比如改了昵称后
        user = Constants.SharedAppDelegate.user

    }

    
    deinit {
        print("PersonInformationTVC deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
