//
//  ChatListViewController.swift
//  RongCloudIM
//
//  Created by Suiyuan Lin on 15/11/24.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 会话列表
*/
class ChatListViewController: RCConversationListViewController {
    
    var user: User!
    
    //
    /* 设置会话类型
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 会话类型
        self.setDisplayConversationTypes([  Type.Privatte.rawValue,
                                            Type.PushService.rawValue,
                                            Type.CustomerService.rawValue,
                                            Type.PublicService.rawValue,
                                            Type.AppService.rawValue,
                                            Type.System.rawValue
                                        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取当前用户
        user = Constants.SharedAppDelegate.user
        
        // 没有内容的行不显示
        conversationListTableView.tableFooterView = UIView()
        
        // 导航栏标题
        title = "会话"
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 隐藏 tabBar
        tabBarController?.tabBar.hidden = false
        
        // 刷新表格
        self.refreshConversationTableViewIfNeeded()
    }
    
    
    /**
     显示右上方菜单
     */
    @IBAction func showMenuBarButton(sender: UIBarButtonItem) {
        //
        /* 使用 KxMenu 添加菜单
        */
        let menuItems = [
            KxMenuItem("发起聊天", image: UIImage(named: "chat_icon"), target: self, action: "pushChat"),
            KxMenuItem("添加好友", image: UIImage(named: "addfriend_icon"), target: self, action: "addFriend"),
            KxMenuItem("客服", image: UIImage(named: "sevre_inactive"), target: self, action: "pushService")
        ]
        var frame = sender.valueForKey("view")?.frame
        frame?.origin.y += 10
        if let frame = frame {
            KxMenu.showMenuInView(self.view, fromRect: frame, menuItems: menuItems)
        }
    }
    /**
     发起聊天
     */
    func pushChat() {
        
        // 跳转到好友列表
        tabBarController?.selectedIndex = 1
        
    }
    //
    /* 添加好友
    */
    func addFriend() {
        
        // 跳转到搜索用户列表
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SearchUserTVC = storyboard.instantiateViewControllerWithIdentifier("SearchUserTableViewController") as! SearchUserTableViewController
        navigationController?.pushViewController(SearchUserTVC, animated: true)
    }
    /**
     * 客服
     */
    func pushService() {
        
        // 跳转到客服界面
        let serviceVC = RCPublicServiceChatViewController()
        serviceVC.conversationType = Type.AppService
        serviceVC.targetId = Constants.ServiceId
        tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(serviceVC, animated: true)
    }
    
    
    // 选择了某一行
    
    override func onSelectedTableRow(conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, atIndexPath indexPath: NSIndexPath!) {
        
        // 隐藏 tabBar
        tabBarController?.tabBar.hidden = true
        
        //
        /* PublicService 类型
        */
        if conversationModelType == ModelType.PublicService {
            let conversationVC = RCPublicServiceChatViewController()
            conversationVC.conversationType = model.conversationType
            conversationVC.targetId = model.targetId
            conversationVC.userName = model.conversationTitle
            conversationVC.title = model.conversationTitle
            
            navigationController?.pushViewController(conversationVC, animated: true)
        }
        //
        /* Normal 类型
        */
        if conversationModelType == ModelType.Normal {
            let conversationVC = RCConversationViewController()
            conversationVC.conversationType = model.conversationType
            conversationVC.targetId = model.targetId
            conversationVC.userName = model.conversationTitle
            conversationVC.title = model.conversationTitle
            conversationVC.unReadMessage = model.unreadMessageCount
            conversationVC.enableNewComingMessageIcon = true
            conversationVC.enableUnreadMessageIcon = true
            if model.conversationType == Type.System {
                conversationVC.userName = "系统消息"
                conversationVC.title = "系统消息"
            }
            navigationController?.pushViewController(conversationVC, animated: true)
        }
        //
        /* Customization 类型
        */
        if conversationModelType == ModelType.Customization {
            print("自定义会话类型")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addFriendRequestTVC = storyboard.instantiateViewControllerWithIdentifier("AddFriendRequestTVC") as! AddFriendRequestTVC
            addFriendRequestTVC.conversationType = model.conversationType
            addFriendRequestTVC.username = model.targetId
            addFriendRequestTVC.nickname = model.conversationTitle
            addFriendRequestTVC.title = model.conversationTitle
            addFriendRequestTVC.conversation = model
            // 这一步很蛋疼的没法实现
            if let user = model.extend as? RCUserInfo {
                addFriendRequestTVC.portraitUrl = user.portraitUri
            }
            navigationController?.pushViewController(addFriendRequestTVC, animated: true)
        }
        
        
    }

    
    
    // MARK: 插入自定义Cell
    
    //
    /* 插入自定义会话model
    */
    override func willReloadTableData(dataSource: NSMutableArray!) -> NSMutableArray! {
        for i in 0 ..< dataSource.count {
            if let model = dataSource[i] as? RCConversationModel {
                //筛选请求添加好友的系统消息，用于生成自定义会话类型的cell
                if model.conversationType == Type.System && model.lastestMessage is RCContactNotificationMessage {
                        model.conversationModelType = ModelType.Customization
                }
            }
        }
        
        return dataSource
    }
    //
    /* 左滑删除
    */
    override func rcConversationListTableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if let model = self.conversationListDataSource[indexPath.row] as? RCConversationModel {
            RCIMClient.sharedRCIMClient().removeConversation(Type.System, targetId: model.targetId)
            self.conversationListDataSource.removeObjectAtIndex(indexPath.row)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(model.targetId)
            self.conversationListTableView.reloadData()
        }
    }
    //
    /* 自定义cell
    */
    override func rcConversationListTableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> RCConversationBaseCell! {
        
        let model = self.conversationListDataSource[indexPath.row] as! RCConversationModel
        var userName = ""
        var portraitUri = ""
        
        
        //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
        //
        /* extend 不为空
        */
        if let extend = model.extend {
            let user = extend as! RCUserInfo
            userName = user.name
            portraitUri = user.portraitUri
        }
        //
        /* extend 为空
        */
        else {
            if let contactNtfMsg = model.lastestMessage as? RCContactNotificationMessage where model.conversationType == Type.System  {
                
                //
                /* 源用户 id 不为空，往下执行，为空则执行花括号里的内容
                */
                guard let sourceUserId = contactNtfMsg.sourceUserId where !sourceUserId.isEmpty else {
                    let cell = RCDChatListCell(style: .Default, reuseIdentifier: "")
                    cell.lblDetail.text = "好友请求"
                    cell.ivAva.setImageWithUrl(portraitUri, placeholderImage: UIImage(named: "system_notice"))
                    return cell
                }
                
                //
                /* 从本地提取用户信息
                */
                if let cacheUserInfo = NSUserDefaults.standardUserDefaults().objectForKey(contactNtfMsg.sourceUserId) as? NSDictionary {
                    userName = cacheUserInfo[Constants.Username] as? String ?? contactNtfMsg.sourceUserId
                    portraitUri = cacheUserInfo[Constants.PortraitUrl] as? String ?? ""
                }
                
                //
                /* 本地无用户信息则从服务器获取用户信息
                */
                else {
                    // 保存空的有什么用？
                    let emptyDic = NSDictionary()
                    NSUserDefaults.standardUserDefaults().setObject(emptyDic, forKey: contactNtfMsg.sourceUserId)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    //
                    /* 获取用户信息
                    */
                    Http.queryForExistObject(contactNtfMsg.sourceUserId, doneCloser: { [unowned self](object, error) -> () in
                        
                        // 用户为空则返回
                        guard object != nil else { return }
                        
                        let userInfo = RCUserInfo()
                        userInfo.name = object[Constants.Nickname] as? String ?? ""
                        userInfo.userId = object[Constants.Username] as! String
                        userInfo.portraitUri = object[Constants.PortraitUrl] as? String ?? ""
                        
                        model.extend = userInfo
                        
                        
                        
                        //
                        /* 缓存到本地
                        */
                        let userInfoDic: NSDictionary = [Constants.Username: userInfo.name, Constants.PortraitUrl: userInfo.portraitUri]
                        NSUserDefaults.standardUserDefaults().setObject(userInfoDic, forKey: contactNtfMsg.sourceUserId)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        self.conversationListTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    })
                }
            }
        }
        
        let cell = RCDChatListCell(style: .Default, reuseIdentifier: "")
        cell.lblDetail.text = "来自\(userName)的好友请求"
        cell.ivAva.setImageWithUrl(portraitUri, placeholderImage: UIImage(named: "system_notice"))
        
        cell.labelTime.text = converMessageTime(Double(model.sentTime / Int64(1000)))
        return cell
    }
    
    //
    /* 转换自定义 cell 消息时间
    */
    private func converMessageTime(secs: Double) -> String {
        
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let messageDate = NSDate(timeIntervalSince1970: secs)
        let messageDayString = formatter.stringFromDate(messageDate)
        
        let nowDate = NSDate(timeIntervalSinceNow: 0)
        let todayString = formatter.stringFromDate(nowDate)
        
        let yesterdayDate = NSDate(timeIntervalSinceNow: -(24 * 60 * 60))
        let yesterdayString = formatter.stringFromDate(yesterdayDate)
        
        var yesterday = ""
        
        if messageDayString == todayString {
            formatter.dateFormat = "HH:mm"
        } else if messageDayString == yesterdayString {
            yesterday = NSBundle.mainBundle().localizedStringForKey("Yesterday", value: "", table: "RongCloudKit")
        }
        
        
        return yesterday.isEmpty ? formatter.stringFromDate(messageDate) : yesterday
    }
    
    // MARK: 收到消息通知-------------------------------------------------
    //
    /* 收到消息通知
    */
    override func didReceiveMessageNotification(notification: NSNotification!) {
        
        let message = notification.object as! RCMessage
        
        //
        /* 如果是添加好友请求消息，进行相应的处理
        */
        if let contactNotificationMsg = message.content as? RCContactNotificationMessage {
            
            // 如果源用户 id 为空，则返回
            guard let sourceUserId = contactNotificationMsg.sourceUserId  where !sourceUserId.isEmpty else {
                return
            }
            
            // 获取用户信息
            Http.queryForExistObject(contactNotificationMsg.sourceUserId, doneCloser: { [unowned self](object, error) -> () in
                
                // 用户为空则返回
                guard object != nil else { return }
                
                // 用户信息
                let userInfo = RCUserInfo()
                userInfo.name = object[Constants.Nickname] as? String ?? ""
                userInfo.userId = object[Constants.Username] as! String
                userInfo.portraitUri = object[Constants.PortraitUrl] as? String ?? ""
                
                // 自定义 ConversationModel
                let customModel = RCConversationModel()
                customModel.conversationModelType = ModelType.Customization
                customModel.extend = userInfo
                customModel.senderUserId = message.senderUserId
                customModel.lastestMessage = contactNotificationMsg
                
                //
                /* 缓存到本地
                */
                let userInfoDic: NSDictionary = [Constants.Nickname: userInfo.name, Constants.PortraitUrl: userInfo.portraitUri]
                NSUserDefaults.standardUserDefaults().setObject(userInfoDic, forKey: contactNotificationMsg.sourceUserId)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                    //调用父类刷新未读消息数
                    self.refreshConversationTableViewWithConversationModel(customModel)
                    self.notifyUpdateUnreadMessageCount()
                    //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
                    if let left = notification.userInfo!["left"] as? NSNumber where left.integerValue == 0 {
                        self.refreshConversationTableViewIfNeeded()
                    }
                    })
                })
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //调用父类刷新未读消息数
                super.didReceiveMessageNotification(notification)
            })
        }
        
        self.refreshConversationTableViewIfNeeded()
        
        
    }
    

    

    deinit {
        print("ChatListViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
