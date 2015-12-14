//
//  AppDelegate.swift
//  RongCloudIM
//
//  Created by Suiyuan Lin on 15/11/23.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RCIMUserInfoDataSource {

    var window: UIWindow?
    
    // 用户
    var user: User? {
        didSet {
            if user != nil {
                // 一旦被设值，就保存数据
                NSKeyedArchiver.archiveRootObject(user!, toFile: User.ArchiveURL.path!)
            }
        }
    }
    // 好友
    var friends: [Friend] = [] {
        didSet {
            // 一旦被设值，就保存数据
            NSKeyedArchiver.archiveRootObject(friends, toFile: Friend.ArchiveFriendsURL.path!)
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 获得 LeanCloud 授权
        AVOSCloud.setApplicationId(Constants.LeanCloudAppId, clientKey: Constants.LeanCloudAppKey)
        
        // 获得 RongCloud 授权
        RCIM.sharedRCIM().initWithAppKey(Constants.RongCloudAppKey)
        
        // 设置数据源 RCIMUserInfoDataSource
        RCIM.sharedRCIM().userInfoDataSource = self
        
        
        // 注册苹果推送
        let types = UIUserNotificationType(rawValue: UIUserNotificationType.Badge.rawValue
                                                   | UIUserNotificationType.Sound.rawValue
                                                   | UIUserNotificationType.Alert.rawValue)
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        //统一导航条样式
        let font = UIFont.systemFontOfSize(19)
        let dict = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = dict
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor(colorLiteralRed: 0x01, green: 0x95, blue: 0xff, alpha: 1)
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "NavigatonBar"), forBarMetrics: .Default)
        

        // 添加观察器
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveMessageNotification:", name: RCKitDispatchMessageNotification, object: nil)
        
        if let friends = NSKeyedUnarchiver.unarchiveObjectWithFile(Friend.ArchiveFriendsURL.path!) as? [Friend] {
            self.friends = friends
        }
        
        // 获取当前用户
        user = NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User
        
        // 用户不在不则跳到启动登录界面
        guard user != nil && !user!.username.isEmpty && !user!.token.isEmpty else {
            // 跳转到登录界面
            turnToLoginVC()
            return true
        }
        Http.getFriendsWithId(user!.username) { _ in }
        
        // 用 token 连接 rongCloud
        RCIM.sharedRCIM().connectWithToken(user?.token,
            success: { [unowned self](string) -> Void in
                
                let currentUserInfo = RCUserInfo(userId: self.user?.username,
                    name: self.user?.nickname,
                    portrait: self.user?.portraitUrl)
                RCIMClient.sharedRCIMClient().currentUserInfo = currentUserInfo
                print("\(string)连接成功！")
//                self.getFriendsWithId(self.user!.username)
                
            },
            error: { (errorCode) -> Void in
                print("\(errorCode)")
                // 跳转到登录界面
                self.turnToLoginVC()
            }) { () -> Void in
                print("Token不正确")
                // 跳转到登录界面
                self.turnToLoginVC()
        }
        
        // 启动会话界面
        self.turnToChatListVC()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
        
    }
    //
    /* 重置桌面图标上的未读消息数量
    */
    func applicationDidEnterBackground(application: UIApplication) {
        let unreadMsgCount = RCIMClient.sharedRCIMClient().getUnreadCount(
            [Type.Privatte.rawValue, Type.Discussion.rawValue, Type.AppService.rawValue, Type.PublicService.rawValue, Type.CustomerService.rawValue]
        )
        application.applicationIconBadgeNumber = Int(unreadMsgCount)
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    
    /**
     接收到消息通知
     */
    func didReceiveMessageNotification(notification: NSNotification) {
        // 应用右上角图标数字加1
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        
        
        if let rcmessage = notification.object as? RCMessage, let rcInfoNtfMsg = rcmessage.content as? RCInformationNotificationMessage {
            let text = rcInfoNtfMsg.message
            if text.hasSuffix("已同意加你为好友") {
                Http.getFriendsWithId(user!.username) { _ in }
                print("已同意加你为好友")
            }
        }
        
    }
    

    
    /**
      跳转到登录界面
     */
    func turnToLoginVC() {
        
        print("进入登录界面")
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: Constants.LoginAndSignupStoryboard, bundle: nil)
        window!.rootViewController = storyboard.instantiateInitialViewController()
        window!.makeKeyAndVisible()
    }
    /**
     跳转到会话界面
     */
    func turnToChatListVC() {
        
        print("进入会话界面")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: Constants.MainStoryboard, bundle: nil)
        self.window!.rootViewController = storyboard.instantiateInitialViewController()
        self.window!.makeKeyAndVisible()
    }
    
    
    // MARK: RCIMUserInfoDataSource
    //
    /* 设置当前用户信息
    */
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        let userInfo = RCUserInfo()
        userInfo.userId = userId
        
        if userId == "linsuiyuan" { // 系统信息
            userInfo.name = "系统消息"
            userInfo.portraitUri = "http://xyk1000.com.img.800cdn.com/images/666.jpg"
        } else if userId == user?.username { // 登录用户信息
            userInfo.portraitUri = user?.portraitUrl
            userInfo.name = user?.nickname ?? (user!.nickname!.isEmpty ? userId : user!.nickname)
        } else  if !friends.isEmpty {
            for friend in friends where friend.username == userId {
                //
                //                    print("\(friend.nickname)")
                userInfo.portraitUri = friend.portraitUrl
                userInfo.name = friend.nickname
            }
        } else {
            userInfo.portraitUri = ""
            userInfo.name = "陌生人"
        }
        
        return completion(userInfo)
        
    }
    

    struct Constants {
        // 这些要替换成自己的
        static let RongCloudAppKey          = "6rv6oe"
        static let LeanCloudAppId           = "XqCITN"
        static let LeanCloudAppKey          = "7LGg5x"
        
        static let LoginAndSignupStoryboard = "LoginAndSignup"
        static let MainStoryboard           = "Main"
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(RCKitDispatchMessageNotification)
    }

}




