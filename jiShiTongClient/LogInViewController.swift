//
//  LogInViewController.swift
//  RongCloudIM
//
//  Created by Suiyuan Lin on 15/11/25.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 登录 ViewController
*/

class LogInViewController: UIViewController, UITextFieldDelegate{
    
    var user: User?
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置文本框代理
        userTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    //
    /* 按下登录按钮
    */
    @IBAction func logInButton(sender: UIButton) {
        //
        /*  验证输入
        */
        guard !userTextField.text!.isEmpty else {
            self.view.showHUDWithText("用户名不能为空!")
            return
        }
        guard !passwordTextField.text!.isEmpty else {
            self.view.showHUDWithText("密码不能为空!")
            return
        }
        
        // 查询用户是否已注册和登录
        checkAndLogIn()
        
    }
    //
    /*  查询用户是否已注册和登录
    */
    func checkAndLogIn() {
        // MARK: 这里按理也应该放在“服务器”-------------------------------------------------
        Http.queryForExistObject(userTextField.text!) { [unowned self](object, error) -> () in
            guard object != nil else {
                // 用户名不存在
                self.view.showHUDWithText("用户名不存在!")
                return
            }
            guard (object["password"] as? String) == self.passwordTextField.text else {
                // 密码不正确
                self.view.showHUDWithText("密码不正确")
                return
            }
            
            // 保存到本地
            let isSuccessfulSave = self.saveUser(object)
            //
            /* 保存成功，进行登录
            */
            if isSuccessfulSave {
                self.userTextField?.resignFirstResponder()
                self.passwordTextField?.resignFirstResponder()
                self.view.showHUDWithText( "登录成功！")
                
                // 1 秒后执行
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { [unowned self]() -> Void in
                    
                    // 给 AppDelegate 的 user 赋值
                    Constants.SharedAppDelegate.user = NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User
                    
                    // 获取好友信息
                    Http.getFriendsWithId((Constants.SharedAppDelegate.user?.username)!) { _ in }
                    
                    // 用 token 连接 rongCloud
                    RCIM.sharedRCIM().connectWithToken(Constants.SharedAppDelegate.user?.token,
                        success: { [unowned self](string) -> Void in
                            // 连接成功
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                print("\(string)连接成功！")
                                // 设置 RCIMClient 的当前用户信息
                                let currentUserInfo = RCUserInfo(userId: self.user?.username, name: self.user?.nickname, portrait: self.user?.portraitUrl)
                                RCIMClient.sharedRCIMClient().currentUserInfo = currentUserInfo
                                // 跳转到会话界面
                                Constants.SharedAppDelegate.turnToChatListVC()
                            })
                        },
                        error: { (errorCode) -> Void in
                            // 连接出错
                            print("\(errorCode)")
                        }) { () -> Void in
                            // token 不正确
                            print("Token不正确")
                    }
                    })
            }
        }

    }
    
    /**
     保存 user
     */
    func saveUser(object: AVObject) -> Bool {
        //
        /* 获取各属性值
        */
        let username = object.objectForKey("username") as! String
        let token = object.objectForKey("token") as! String
        let email = object.objectForKey("email") as! String
        let nickname = object.objectForKey("nickname") as? String
        let portraitUrl = object["portraitUrl"] as? String
        
        //
        /* 用户名和 token 不为空时保存用户
        */
        if !username.isEmpty && !token.isEmpty {
            self.user = User(username: username, email: email, token: token)
            self.user?.nickname = nickname
            self.user?.portraitUrl = portraitUrl
            if let user = self.user {
                print("\(user)")
                // 保存用户到本地
                return NSKeyedArchiver.archiveRootObject(user, toFile: User.ArchiveURL.path!)
            }
        }
        return false
    }
    
    
    // MARK: UITextFieldDelegate
    //
    /* 按下返回键，关闭键盘
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //
    /* 点击键盘以外区域，关闭键盘
    */
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    
    deinit {
        print("LoginViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }
}
