//
//  PortraitVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 头像 ViewController
*/
class PortraitVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Constants.SharedAppDelegate.user

        imageView.image = user?.portrait
        
        let barButton = UIBarButtonItem(title: "上传新头像", style: .Plain, target: self, action: "tappedBarButton")
        navigationItem.rightBarButtonItem = barButton
        
    }

    func tappedBarButton() {
        //
        print("按了“上传新头像”按钮")
        view.showHUDWithText("此功能还未实现，敬请期待！")
    }
    


    
    deinit {
        print("PortraitVC deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
