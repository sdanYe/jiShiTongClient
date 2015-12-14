//
//  ContactsTableViewController.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/1.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 联系人 ViewController
*/

class ContactsTableViewController: UITableViewController {
    
    var friends = [Friend]() {
        didSet {
            // 刷新列表
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给 friends 赋值
        self.friends = Constants.SharedAppDelegate.friends
        
        // 没有内容的行不显示
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // 显示 tabBar
        tabBarController?.tabBar.hidden = false
        // 刷新列表
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    //
    /* 显示多少部分
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    //
    /* 显示多少行
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    //
    /* 每行显示的内容
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactsCell", forIndexPath: indexPath) as! ContactsTableViewCell

        cell.friend = friends[indexPath.row]
        return cell
    }
    //
    /* 手动刷新列表
    */
    @IBAction func refreshTableView(sender: UIRefreshControl) {
        // 获取好友
        Http.getFriendsWithId(Constants.SharedAppDelegate.user!.username) { (friends) -> Void in
            print("刷新朋友")
            self.friends = friends
            // 结束 refreshControl 的旋转
            sender.endRefreshing()
        }
    }
    

    
    // MARK: - Navigation

    //
    /* 给目的 ViewController 的 friend 传值
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ContactCardSegue" {
            if let destinationTVC = segue.destinationViewController as? ContactCardTableViewController {
                if let cell = sender as? ContactsTableViewCell {
                    let indexPath = tableView.indexPathForCell(cell)!
                    destinationTVC.friend = friends[indexPath.row]
                }
            }
        }
    }
    
    deinit {
        print("ContactsTableViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }
    

}
