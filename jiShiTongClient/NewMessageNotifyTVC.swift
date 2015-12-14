//
//  NewMessageNotifyTVC.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/4.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 新消息通知 ViewController
*/
class NewMessageNotifyTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    @IBAction func switchs(sender: UISwitch) {
        view.showHUDWithText("目前还不能关闭哦，敬请期待！")
        sender.on = true
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            
            view.showHUDWithText("此功能还未实现，敬请期待！")
            print("点击了“消息免打扰cell”")
            
            // 清除 cell 选中状态
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            cell.selected = false
        }
        
    }
    
    
    deinit {
        print("NewMessageNotifyTVC deinit")
        print("----------------------------------------------------------------------------------------")
    }

}
