//
//  Friend.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/1.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit
//
/* 存放好友信息的类，继承自 User 类
*/
class Friend: User {
    //
    /* 保存好友的路径
    */
    static let ArchiveFriendsURL = DocumentsDirectory.URLByAppendingPathComponent("friends")
    
    //
    /* 指定构造器
    */
    init(username: String, email: String) {
        
        super.init(username: username, email: email, token: "")
    }
    //
    /* NSCoding, 便利构造器
    */
    required convenience init?(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObjectForKey(Key.UsernameKey) as! String
        let email = aDecoder.decodeObjectForKey(Key.EmailKey) as! String
        let nickname = aDecoder.decodeObjectForKey(Key.NicknameKey ) as? String
        let portrait = aDecoder.decodeObjectForKey(Key.PortraitKey ) as? UIImage
        let constellation = aDecoder.decodeObjectForKey(Key.ConstellationKey) as? String
        let portraitUrl = aDecoder.decodeObjectForKey(Key.PortraitUrlKey) as? String
        
        
        self.init(username: username, email: email)
        
        self.nickname = nickname
        self.portrait = portrait
        self.constellation = constellation
        self.portraitUrl = portraitUrl
    }
    
}