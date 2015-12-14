//
//  MeTableViewController.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/3.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit
import Alamofire

//
/* 我 ViewController
*/

class MeTableViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User! {
        didSet {
            imageView.image = user.portrait
            nicknameLabel.text = user.nickname
            usernameLabel.text = user.username
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏标题
        title = "我"
        
        // 给当前用户赋值
        user = Constants.SharedAppDelegate.user
        
        // 设置当前用户头像
        if user.portrait == nil {
            
            // 设置默认头像，当成功从网格取回头像时，该头像将被替换
            imageView.image = Constants.DefaultPortrait
            
            // 通过 url 获取头像
            if let url = user.portraitUrl where !url.isEmpty {
                Alamofire.request(.GET, url).response(completionHandler: { (request, response, nsData, error) -> Void in
                    // 获得图片
                    if let data = nsData, image = UIImage(data: data) {
                        dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                            // 显示头像
                            self.imageView.image = image
                            
                            // 保存头像
                            self.user.portrait = image
                            if let user = self.user {
                                NSKeyedArchiver.archiveRootObject(user, toFile: User.ArchiveURL.path!)
                            }
                            })
                        
                    } else {
                        //
                        print("\(error.debugDescription)")
                    }
                })
            
            }
        }
        
    }
    
    //
    /* 保持及时刷新信息
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        user = Constants.SharedAppDelegate.user
    }


    
    deinit {
        print("MeTableViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
