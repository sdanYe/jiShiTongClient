//
//  NicknameVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 修改昵称 ViewController
*/

class NicknameVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var nicknameTextField: UITextField! 
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置文本框代理
        nicknameTextField.delegate = self
        // 显示昵称
        nicknameTextField.text = user?.nickname
        
        // 给 user 赋值
        user = Constants.SharedAppDelegate.user

        // 添加“保存”按钮
        let barButton = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "tappedBarButton")
        navigationItem.rightBarButtonItem = barButton
        
        // 昵称文本框获取焦点
        nicknameTextField.becomeFirstResponder()
    }
    //
    /* 保存修改后的昵称
    */
    func tappedBarButton() {
        print("按了保存按钮")
        
        // 获取当前用户的信息
        Http.queryForExistObject(user!.username) { [unowned self](object, error) -> () in
            if object != nil {
                
                // 替换昵称
                object[Constants.Nickname] = self.nicknameTextField.text
                
                // 保存替换后的用户信息
                object.saveInBackgroundWithBlock({ (bool, error) -> Void in
                    if bool {
                        print("昵称保存成功")
                        self.view.showHUDWithText("昵称保存成功")
                        
                        // 刷新 AppDelegate 中的用户信息
                        let user = Constants.SharedAppDelegate.user
                        user?.nickname = self.nicknameTextField.text
                        Constants.SharedAppDelegate.user = user
                        
                    } else {
                        print("昵称保存失败")
                    }
                })
            } else {
                print("获取当前用户的信息失败")
            }
        }
    }
    //
    /* 点击键盘以外的区域，关闭键盘
    */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nicknameTextField.resignFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    //
    /* 按下返回键，关闭键盘
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    deinit {
        print("NicknameVC deinit")
        print("----------------------------------------------------------")
    }
    

}
