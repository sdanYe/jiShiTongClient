//
//  HUD.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import Foundation
import MBProgressHUD
import Alamofire


// MARK: - 扩展 UIView, 增加显示提示信息方法，这里使用到 MBProgressHUD

extension UIView {
    /* 显示提示信息，自动隐藏
    默认显示 1 秒
    */
    func showHUDWithText(text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
        hud.mode = .Text
        hud.labelText = text
        hud.center = self.center
        hud.margin = 10
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 1)
    }
    //
    /* 显示提示信息，没有自动隐藏
    */
    func showHUDWithText(text: String, delegate: MBProgressHUDDelegate) -> MBProgressHUD {
        let HUD = MBProgressHUD(view: self)
        self.addSubview(HUD)
        HUD?.delegate = delegate
        HUD?.labelText = text
        HUD?.show(true)
        return HUD
    }
}

// MARK: - 扩展 AVObject ，增加 friend 属性，返回 Friend 类型

extension AVObject {
    var friend: Friend {
        let username         = self[Constants.Username]      as! String
        let nickname         = self[Constants.Nickname]      as? String
        let email            = self[Constants.Email]         as! String
        let sex              = self[Constants.Sex]           as? String
        let constellation    = self[Constants.Constellation] as? String
        let portraitUrl      = self[Constants.PortraitUrl]   as? String
        
        let friend           = Friend(username: username, email: email)
        friend.nickname      = nickname
        friend.sex           = sex
        friend.constellation = constellation
        friend.portraitUrl   = portraitUrl
        return friend
    }
}


// MARK: - 扩展 UIViewController
extension UIViewController {
    //
    /* 该警告框默认有“取消”、“确定”两个选项
    */
    func showAlertWithTitle(title: String, message: String, suerCloser: (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: message, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (alertAction) -> Void in
            // 点击确定后的动作
            suerCloser(alertAction)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - ImageView

extension UIImageView {
    
    //
    /* 通过 URL 设置图片
    */
    func setImageWithUrl(url: String?, placeholderImage: UIImage?) {
        self.image = placeholderImage
        if let url = url {
            Alamofire.request(.GET, url).responseData({ [unowned self](response) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let data = response.data, image = UIImage(data: data) {
                        self.image = image
                    }
                })
            })
        }
    }

}























