//
//  Http.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/11/28.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

// 这个也可以写到extensions里面
class Http: NSObject {
    
    //
    /* 获取用户信息
    */
    class func queryForExistObject(searchText: String, doneCloser: (object: AVObject!, error: NSError!) -> () ) {
        let query = AVQuery(className: Constants.LeanCloudClassName)
        query.whereKey(Constants.Username, equalTo: searchText)
        query.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            doneCloser(object: object, error: error)
        }
    }
    //
    /* 根据前缀获取多个用户信息
    */
    class func queryForObjects(searchText: String, doneCloser: (objects: [AVObject]!, error: NSError!) -> () ) {
        // 查询服务端，用户是否已注册
        let query = AVQuery(className: Constants.LeanCloudClassName)
        query.whereKey(Constants.Username, containsString: searchText)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let objects = objects as? [AVObject] {
                doneCloser(objects: objects, error: error)
            }
            
        }
    }
    //
    /* 获取好友信息
    */
    class func getFriendsWithId(userId: String, doneCloser: ([Friend]) -> Void) {
        
        let query = AVQuery(className: Constants.LeanCloudClassName)
        query.whereKey(Constants.Username, equalTo: userId)
        query.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            
            if object != nil {
                print("查询用户成功")
                let query = AVQuery(className: Constants.LeanCloudClassName)
                if let friends = object["friends"] as? [String] {
                    query.whereKey(Constants.Username, containedIn: friends )
                    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        if let objects = objects as? [AVObject] where !objects.isEmpty {
                            //
                            print("获取用户好友成功")
                            
                            Constants.SharedAppDelegate.friends = objects.map({ $0.friend  })
                            doneCloser(Constants.SharedAppDelegate.friends)
                        } else {
                            doneCloser(Constants.SharedAppDelegate.friends)
                            print("获取好友失败")
                        }
                        
                        })
                } else {
                    doneCloser(Constants.SharedAppDelegate.friends)
                    print("该用户没有还没有好友")
                }
                
            } else {
                print("查询用户失败")
            }
        })
        
    }

    
    deinit {
        print("Http deinit")
        print("----------------------------------------------------------------------------------------")
    }
}