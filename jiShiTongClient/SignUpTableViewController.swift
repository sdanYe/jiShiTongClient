//
//  SignUpTableViewController.swift
//  RongCloudIM
//
//  Created by Suiyuan Lin on 15/11/25.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit
import MBProgressHUD

//
/* 注册 ViewController
*/
class SignUpTableViewController: UITableViewController, UITextFieldDelegate, MBProgressHUDDelegate, AVIMClientDelegate {
    
    var textField: UITextField!// 用于记录当前 textField ，以便于关闭键盘，比如在按下导航栏上的按钮时
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField! 
    @IBOutlet weak var constellationTextField: UITextField!
    @IBOutlet weak var sexSegment: UISegmentedControl!
    
    // leanCloud 聊天声明
    var client: AVIMClient!
    // 计时器声明，用于检查注册超时
    var timer: NSTimer?
    // hud，用于在屏幕上显示提示信息
    var HUD: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        /* 设置文本框代理
        */
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        nicknameTextField.delegate = self
        constellationTextField.delegate = self
        
        // 随机产生一个用户名，用于开启 leanCloud 聊天
        let name = "client\(arc4random() / 10000)"
        //
        /* 开启聊天
        */
        client = AVIMClient()
        client.delegate = self
        client.openWithClientId(name, callback: { (bool, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if bool {
                    print("\(name)开启聊天成功\n----------------------------------------------------------")
                } else {
                    print("\(name)开启聊天失败\n----------------------------------------------------------")
                }
            })
        })
        
        
        
    }
    //
    /* userNameTextField 获取焦点
    */
    override func viewDidAppear(animated: Bool) {
        userNameTextField.becomeFirstResponder()
    }

    /**
     取消注册
     */
    @IBAction func cancelBarButton(sender: UIBarButtonItem) {
        textField?.resignFirstResponder() // 关闭键盘
        dismissViewControllerAnimated(true) { () -> Void in
            //
            print("取消了注册")
        }
    }
    /**
     完成注册
     */
    @IBAction func doneBarButton(sender: UIBarButtonItem) {
        //
        /* 验证输入
        */
        guard !userNameTextField.text!.isEmpty else {
            view.showHUDWithText("用户名不能为空！")
            userNameTextField.becomeFirstResponder() // 聚焦 userNameTextField
            return
        }
        let count = passwordTextField.text!.characters.count
        guard count >= 6 && count <= 20 else {
            view.showHUDWithText("密码长度为6到20位!")
            passwordTextField.becomeFirstResponder() // 聚焦 passwordTextField
            return
        }
        guard let email = emailTextField.text where !email.isEmpty else {
            view.showHUDWithText("邮箱不能为空！")
            emailTextField.becomeFirstResponder() // 聚焦 emailTextField
            return
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        guard predicate.evaluateWithObject(email) else {
            view.showHUDWithText("邮箱格式不对！")
            emailTextField.becomeFirstResponder() // 聚焦 emailTextField
            return
        }
        
        // 关闭键盘
        self.textField?.resignFirstResponder()
        
        // 计时器计数清0，开启计时器
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "checkTokenValue", userInfo: nil, repeats: false)
        
        HUD = view.showHUDWithText("正在注册...", delegate: self)
        
        print("正在注册...")
        // 注册用户
        signUpUser()
        
        
    }
    /**
     注册用户
     */
    func signUpUser() {
        // MARK: 这里应该放在“服务器”上-------------------------------------------------
        // 查询服务端，用户是否已注册
        Http.queryForExistObject(userNameTextField.text!) { [unowned self](object, error) -> () in
            guard object == nil else {
                self.timer?.invalidate()
                self.HUD?.hidden = true
                self.view.showHUDWithText("用户已被注册!！")
                return
            }
            // 未被注册，发送获取 token 消息进行注册
            self.client.createConversationWithName("获取token", clientIds: ["server"], callback: { (conversation, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                    let username = self.userNameTextField.text!
                    let message = "/user/getToken-\(username)"
                    conversation.sendMessage(AVIMTextMessage(text: message, attributes: nil), callback: { (bool, error) -> Void in
                        if bool {
                            print("获取token消息发送成功")
                        } else {
                            print("获取token消息发送失败")
                        }
                    })
                })
            })

        }
    }
    //
    /* 检查是否超时，超时时间为 10 秒
    */
    func checkTokenValue() {
        timer?.invalidate()
        HUD?.hidden = true
        // MARK: 有个 Bug ，服务器没在线，超时后服务器上线，会继续发来 token
        // 如果此时客户端已关闭注册页面，则无法再进行正常注册
        view.showHUDWithText("连接超时！")
    }
    //
    /* 保存用户
    */
    func saveUserWithToken(token: String) {
        // 获取 user 实例
        let user = AVObject(className: "SYUsers")
        user["username"]      = userNameTextField.text
        user["nickname"]      = nicknameTextField.text
        user["password"]      = passwordTextField.text
        user["email"]         = emailTextField.text
        user["token"]         = token
        user["constellation"] = constellationTextField.text
        user["sex"]           =  {
            switch sexSegment.selectedSegmentIndex {
            case 0: return "男"
            case 1: return "女"
            default: return "保密"
            }
        }()
        // 后台保存 user
        user.saveInBackgroundWithBlock { [unowned self](bool, error) -> Void in
            if bool {
                self.view.showHUDWithText("注册成功！")
                // 1 秒后执行
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { [unowned self]() -> Void in
                    // 关闭当前 ViewController
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            } else {
                 self.view.showHUDWithText( "注册失败！")
            }
        }
    }
    
    
    
    
    
    // MARK: UITextFieldDelegate
    //
    /* 开始输入时，记录当前 textField ，以便于关闭键盘
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.textField = textField
        return true
    }
    //
    /* 按下返回键时，关闭键盘
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //
    /* 结束输入
    */
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == passwordTextField {
            let count = textField.text!.characters.count
            if count < 6 || count > 20 {
                // 提示密码长度不符
                self.view.showHUDWithText( "密码长度为6到20位!")
            }
        } else if textField == emailTextField {
            // 邮箱验证正则表达式
            let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
            guard predicate.evaluateWithObject(textField.text!) else {
                // 提示邮箱格式不符
                self.view.showHUDWithText( "邮箱格式不对!")
                return
            }
        }
    }
    
    // MARK: MBProgressHUDDelegate
    //
    /* 隐藏 hud 后
    */
    func hudWasHidden(hud: MBProgressHUD!) {
        // 移除 hud
        hud.removeFromSuperview()
    }
    
    
    // MARK: AVIMClientDelegate
    //
    /* 收到服务端消息
    */
    func conversation(conversation: AVIMConversation!, didReceiveTypedMessage message: AVIMTypedMessage!) {
        print("收到服务端消息")
        if let token = message.text {
            timer?.invalidate()
            HUD?.hidden = true
            print("token: \(token)")
            saveUserWithToken(token)
        }
    }
    
    deinit {
        print("SignUpTableViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
