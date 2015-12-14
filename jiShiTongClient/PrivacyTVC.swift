//
//  PrivacyTVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 隐私 ViewController
*/

class PrivacyTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    @IBAction func switchDidTapped(sender: UISwitch) {
        view.showHUDWithText("目前还不能关闭哦，敬请期待！")
        sender.on = true
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            view.showHUDWithText("此功能还未实现，敬请期待！")
            print("点击了“黑名单cell”")
            
            // 清除 cell 选中状态
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.selected = false
        }
    }

}
