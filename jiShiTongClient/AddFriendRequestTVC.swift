//
//  AddFriendRequestTVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 添加好友请求 ViewController
*/

class AddFriendRequestTVC: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var extraMessageLabel: UILabel!
    
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var refuseButton: UIButton!
    @IBOutlet weak var agreeOrRefuseLabel: UILabel!
    
    var username: String!
    var nickname: String!
    var portraitUrl: String?
    var conversationType: RCConversationType!
    var conversation: RCConversationModel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏标题
        title = "请求添加好友"
        // 显示用户名
        usernameLabel.text = username
        // 显示附加信息
        extraMessageLabel.text = "来自\(username)的好友请求"
        
        // 设置头像
        if let cacheUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(username) as? NSDictionary {            portraitUrl = cacheUserInfo[Constants.PortraitUrl] as? String
            imageView.setImageWithUrl(portraitUrl, placeholderImage: Constants.DefaultPortrait)
        }
        
        //
        /* 若已经点击过同意或拒绝按钮，则使它们不可用
        */
        if let dict = NSUserDefaults.standardUserDefaults().objectForKey(username) as? [String: AnyObject] {
            if let agree = dict["agree"] as? Bool {
                agreeButton.enabled = false
                refuseButton.enabled = false
                if agree == true {
                    agreeOrRefuseLabel.text = "你已添加对方为好友"
                } else {
                    agreeOrRefuseLabel.text = "你已拒绝加对方为好友"
                }
            }
        }
        
        
        
        
    }
    
    @IBAction func agreeButton(sender: UIButton) {
        print("按了同意按钮")
        
        // 保存同意状态
        if var dict = NSUserDefaults.standardUserDefaults().objectForKey(username) as? [String: AnyObject] {
            dict["agree"]  = true
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: username)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // 设置按钮为不可用状态
        agreeButton.enabled = false
        refuseButton.enabled = false
        agreeOrRefuseLabel.text = "你已添加对方为好友"
        
        //
        /* 向服务器发送同意加好友消息
        */
        let client = AVIMClient()
        // 开启聊天连接
        client.openWithClientId(username, callback: { (bool, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                if bool {
                    print("\(self.username)开启LeanCloud聊天成功")
                    
                    // 获取当前用户及好友 id
                    let userId = RCIMClient.sharedRCIMClient().currentUserInfo.userId
                    let friendId = self.username
                    
                    // 组合信息内容
                    let message = "/message/system/publish-agreeAddFriend-\(userId)-\(friendId)"
                    
                    // 创建会话
                    client.createConversationWithName("同意加好友", clientIds: ["server"], callback: { (conversation, error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // 发送信息
                            conversation.sendMessage(AVIMTextMessage(text: message, attributes: nil), callback: { (bool, error) -> Void in
                                if bool {
                                    // 发送成功
                                    print("同意加好友消息发送成功")
                                    self.view.showHUDWithText("同意加好友消息发送成功")
                                    
                                    // 关闭聊天连接
                                    client.closeWithCallback({ (bool, error) -> Void in
                                        if bool {
                                            print("成功关闭LeanCloud聊天")
                                        }
                                    })
                                } else {
                                    print("同意加好友消息发送失败")
                                }
                            })
                        })
                    })
                    
                } else {
                    print("\(self.username)开启LeanCloud聊天失败")
                }
                })
        })

        
    }
    
    @IBAction func refuseButton(sender: UIButton) {
        print("按了拒绝按钮")
        
        // 保存拒绝状态
        if var dict = NSUserDefaults.standardUserDefaults().objectForKey(username) as? [String: AnyObject] {
            dict["agree"]  = false
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: username)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // 设置按钮为不可用状态
        agreeButton.enabled = false
        refuseButton.enabled = false
        agreeOrRefuseLabel.text = "你已拒绝加对方为好友"
        
        //
        /* 向服务器发送拒绝加好友消息
        */
        let client = AVIMClient()
        // 开启聊天连接
        client.openWithClientId(username, callback: { (bool, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                if bool {
                    print("\(self.username)开启LeanCloud聊天成功")
                    
                    // 获取当前用户及好友 id
                    let userId = RCIMClient.sharedRCIMClient().currentUserInfo.userId
                    let friendId = self.username
                    
                    // 组合信息内容
                    let message = "/message/system/publish-refuseAddFriend-\(userId)-\(friendId)"
                    
                    // 创建会话
                    client.createConversationWithName("拒绝加好友", clientIds: ["server"], callback: { (conversation, error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // 发送信息
                            conversation.sendMessage(AVIMTextMessage(text: message, attributes: nil), callback: { (bool, error) -> Void in
                                if bool {
                                    
                                    // 发送成功
                                    print("拒绝加好友消息发送成功")
                                    self.view.showHUDWithText("拒绝加好友消息发送成功")
                                    
                                    // 关闭聊天连接
                                    client.closeWithCallback({ (bool, error) -> Void in
                                        if bool {
                                            print("成功关闭LeanCloud聊天")
                                        }
                                    })
                                } else {
                                    print("拒绝加好友消息发送失败")
                                }
                            })
                        })
                    })
                    
                } else {
                    print("\(self.username)开启LeanCloud聊天失败")
                }
                })
        })

    }

    

}
