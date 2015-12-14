//
//  SettingTVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 设置 ViewController
*/
class SettingTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
        /* 清除缓存
        */
        if indexPath.section == 1 && indexPath.row == 0 {
            // 显示警告框
            self.showAlertWithTitle("清除缓存", message: "确定清除缓存？", suerCloser: { (_) -> Void in
                print("确定清除缓存")
                self.view.showHUDWithText("此功能还未实现，敬请期待！")
            })
        }
        //
        /* 退出登录
        */
        if indexPath.section == 3 && indexPath.row == 0 {
            // 显示警告框
            self.showAlertWithTitle("退出登录", message: "确定退出登录", suerCloser: { (_) -> Void in
                print("确定退出登录")
                
                let appDelegate = Constants.SharedAppDelegate
                // 清除当前用户信息
                appDelegate.user = User()
                // 清除当前好友信息
                appDelegate.friends = []
                
                // 释放当前的 window
                appDelegate.window = nil
                
                // 断开连接
                RCIM.sharedRCIM().disconnect()
                
                // 转到登录界面
                appDelegate.turnToLoginVC()

            })
        }
        // 清除 cell 的选中状态
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.selected = false
    }

    
    deinit {
        print("SettingTVC deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
