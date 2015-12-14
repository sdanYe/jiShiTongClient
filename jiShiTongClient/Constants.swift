//
//  Constants.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/2.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit


struct Type {
    static let System          = RCConversationType.ConversationType_SYSTEM
    static let Privatte        = RCConversationType.ConversationType_PRIVATE
    static let Group           = RCConversationType.ConversationType_GROUP
    static let PublicService   = RCConversationType.ConversationType_PUBLICSERVICE
    static let ChatRoom        = RCConversationType.ConversationType_CHATROOM
    static let Discussion      = RCConversationType.ConversationType_DISCUSSION
    static let AppService      = RCConversationType.ConversationType_APPSERVICE
    static let PushService     = RCConversationType.ConversationType_PUSHSERVICE
    static let CustomerService = RCConversationType.ConversationType_CUSTOMERSERVICE
}

struct ModelType {
    static let Collection      = RCConversationModelType.CONVERSATION_MODEL_TYPE_COLLECTION
    static let Normal          = RCConversationModelType.CONVERSATION_MODEL_TYPE_NORMAL
    static let Customization   = RCConversationModelType.CONVERSATION_MODEL_TYPE_CUSTOMIZATION
    static let PublicService   = RCConversationModelType.CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE
}

struct Constants {
    
    static let LeanCloudClassName = "SYUsers"
    
    static let ServiceId          = "KEFU144838704743662"
    
    static let DefaultPortrait    = UIImage(named: "icon_person")
    
    static let Username           = "username"
    static let Nickname           = "nickname"
    static let Email              = "email"
    static let Password           = "password"
    static let Constellation      = "constellation"
    static let Sex                = "sex"
    static let Portrait           = "portrait"
    static let PortraitUrl        = "portraitUrl"
    
    static let SharedAppDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
}



