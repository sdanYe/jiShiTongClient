//
//  ContactsTableViewCell.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/1.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 联系人 ViewCell
*/

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    var friend: Friend! {
        didSet {
            // 显示昵称和头像
            nicknameLabel?.text = friend.nickname
            portraitImageView.image = friend.portrait
            
            if friend.portrait == nil {
                // 通过网络设置头像
                portraitImageView.setImageWithUrl(friend.portraitUrl, placeholderImage: Constants.DefaultPortrait)
            }
        }
    }
    

    
    deinit {
        print("ContactsTableViewCell deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
