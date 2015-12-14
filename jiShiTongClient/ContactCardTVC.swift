//
//  ContactTableViewController.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/1.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 联系卡 ViewController
*/
class ContactCardTableViewController: UITableViewController {
    
    // 头像imageView
    @IBOutlet weak var portraitImageView: UIImageView!
    // 昵称label
    @IBOutlet weak var nicknameLabel: UILabel!
    // 用户名label
    @IBOutlet weak var usernameLabel: UILabel!
    // 邮箱label
    @IBOutlet weak var emailLabel: UILabel!
    // 星座label
    @IBOutlet weak var constellationLabel: UILabel!
    
    // 添加好友或发送消息按钮
    @IBOutlet weak var addFriendOrSendMsgButton: UIButton!
    
    
    var friend: Friend!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取好友列表用户名
        let friendUsernames = Constants.SharedAppDelegate.friends.map { $0.username }
        
        // 如果好友列表用户名包含当前用户名，按钮标题显示“发送消息”，否则显示“添加好友”
        if friendUsernames.contains(friend.username) {
            addFriendOrSendMsgButton.setTitle("发送消息", forState: .Normal)
        } else {
            addFriendOrSendMsgButton.setTitle("添加好友", forState: .Normal)
        }
        
        // 显示用户名、昵称、邮箱和星座信息
        nicknameLabel.text = friend.nickname
        usernameLabel.text = friend.username
        emailLabel.text = friend.email
        constellationLabel.text = friend.constellation
        // 显示头像
        portraitImageView.image = friend.portrait
        if friend.portrait == nil {
            // 通过网络设置头像
            portraitImageView.setImageWithUrl(friend.portraitUrl, placeholderImage: Constants.DefaultPortrait)
        }
    }
    
    //
    /* 发送消息
    */
    @IBAction func sendMessageButton(sender: UIButton) {
        
        // 设置将要 push 的 conversationVC
        let conversationVC = RCConversationViewController()
        conversationVC.conversationType = Type.Privatte
        conversationVC.targetId = friend.username
        conversationVC.userName = friend.nickname
        conversationVC.title = friend.nickname
        conversationVC.enableNewComingMessageIcon = true
        conversationVC.enableUnreadMessageIcon = true
        
        // push conversationVC
        navigationController?.pushViewController(conversationVC, animated: true)
        
        // 隐藏 tabBar
        tabBarController?.tabBar.hidden = true
    }
    //
    /* 发送消息或添加好友
    */
    @IBAction func addFriendButton(sender: UIButton) {
        
        //
        /* 发送消息
        */
        if addFriendOrSendMsgButton.currentTitle == "发送消息" {
            
            // 设置将要 push 的 conversationVC
            let conversationVC = RCConversationViewController()
            conversationVC.conversationType = Type.Privatte
            conversationVC.targetId = friend.username
            conversationVC.userName = friend.nickname
            conversationVC.title = friend.nickname
            conversationVC.enableNewComingMessageIcon = true
            conversationVC.enableUnreadMessageIcon = true
            
            // push conversationVC
            navigationController?.pushViewController(conversationVC, animated: true)
            
            // 隐藏 tabBar
            tabBarController?.tabBar.hidden = true
        }
        
        //
        /* 添加好友
        */
        else if addFriendOrSendMsgButton.currentTitle == "添加好友" {
            let client = AVIMClient()
            // 开启聊天连接
            client.openWithClientId(friend.username, callback: { (bool, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                    if bool {
                        print("\(self.friend.username)开启LeanCloud聊天成功")
                        
                        // 获取用户和好友 id
                        let userId = RCIMClient.sharedRCIMClient().currentUserInfo.userId
                        let friendId = self.friend.username
                        
                        // 组合消息内容
                        let message = "/message/system/publish-requestAddFriend-\(userId)-\(friendId)"
                        
                        // 创建会话
                        client.createConversationWithName("请求加好友", clientIds: ["server"], callback: { (conversation, error) -> Void in
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                // 发送消息
                                conversation.sendMessage(AVIMTextMessage(text: message, attributes: nil), callback: { (bool, error) -> Void in
                                    if bool {
                                        
                                        print("请求加好友消息发送成功")
                                        self.view.showHUDWithText("请求加好友消息发送成功")
                                        
                                        // 成功发送之后就要重新加载 好友列表
                                        Http.getFriendsWithId(Constants.SharedAppDelegate.user!.username) { _ in }
                                        
                                        // 关闭聊天连接
                                        client.closeWithCallback({ (bool, error) -> Void in
                                            if bool {
                                                print("成功关闭LeanCloud聊天")
                                            }
                                        })
                                    } else {
                                        print("请求加好友消息发送失败")
                                    }
                                })
                            })
                        })
                        
                    } else {
                        print("\(self.friend.username)开启LeanCloud聊天失败")
                    }
                    })
            })

        }
        
    }
    
    deinit {
        print("ContactCardTableViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }
    
}
