//
//  User.swift
//  RongCloudIM
//
//  Created by Suiyuan Lin on 15/11/24.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import Foundation
//
/* 保存用户信息的类
*/
class User: NSObject, NSCoding {
    // 必要属性
    var username: String = ""
    var email: String = ""
    var token: String = ""
    // 可选属性
    var sex: String?
    var nickname: String?
    var portraitUrl: String?
    var constellation: String?
    var portrait: UIImage?
    //
    /* 保存 User 的路径
    */
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    //
    /* 指定构造器
    */
    override init() {
       super.init()
    }
    //
    /* 指定构造器
    */
    init(username: String, email: String, token: String) {
        self.username = username
        self.email = email
        self.token = token
        
        super.init()
        
        
    }
    //
    /* NSCoding，便利构造器
    */
    convenience required init?(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObjectForKey(Key.UsernameKey) as! String
        let email = aDecoder.decodeObjectForKey(Key.EmailKey) as! String
        let token = aDecoder.decodeObjectForKey(Key.TokenKey) as! String
        let nickname = aDecoder.decodeObjectForKey(Key.NicknameKey ) as? String
        let sex = aDecoder.decodeObjectForKey(Key.SexKey ) as? String
        let portraitUrl = aDecoder.decodeObjectForKey(Key.PortraitUrlKey ) as? String
        let constellation = aDecoder.decodeObjectForKey(Key.ConstellationKey ) as? String
        let portrait = aDecoder.decodeObjectForKey(Key.PortraitKey) as? UIImage
        
        self.init(username: username, email: email, token: token)
        
        self.nickname = nickname 
        self.sex = sex
        self.portraitUrl = portraitUrl
        self.constellation = constellation
        self.portrait = portrait
    }
    //
    /* 便利构造器
    */
    convenience init?(username: String, nickname: String?, email: String, constellation: String?, portraitUrl: String?, portrait: UIImage?) {
        self.init(username: username, email: email, token: "")
        self.nickname = nickname
        self.portraitUrl = portraitUrl
        self.constellation = constellation
        self.portrait = portrait
    }
    //
    /* NSCoding
    */
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: Key.UsernameKey)
        aCoder.encodeObject(email, forKey: Key.EmailKey)
        aCoder.encodeObject(token, forKey: Key.TokenKey)
        aCoder.encodeObject(nickname, forKey: Key.NicknameKey)
        aCoder.encodeObject(sex, forKey: Key.SexKey)
        aCoder.encodeObject(portraitUrl, forKey: Key.PortraitUrlKey)
        aCoder.encodeObject(constellation, forKey: Key.ConstellationKey)
        aCoder.encodeObject(portrait, forKey: Key.PortraitKey)
    }
    //
    /* 常量
    */
    struct Key {
        static let UsernameKey = "username"
        static let EmailKey = "email"
        static let TokenKey = "token"
        static let NicknameKey = "nickname"
        static let SexKey = "sex"
        static let PortraitUrlKey = "portraitUrl"
        static let ConstellationKey = "constellation"
        static let PortraitKey = "portrait"
    }
    
    deinit {
        print("User deinit")
        print("----------------------------------------------------------------------------------------")
    }
}


























