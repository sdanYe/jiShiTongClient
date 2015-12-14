//
//  SearchUserTableViewController.swift
//  jiShiTongClient
//
//  Created by Suiyuan Lin on 15/12/1.
//  Copyright © 2015年 Suiyuan Lin. All rights reserved.
//

import UIKit

//
/* 搜索用户 ViewController
*/

class SearchUserTableViewController: UITableViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            // 设置代理
            searchBar.delegate = self
            // 显示 “取消” 按钮
            searchBar.showsCancelButton = true
        }
    }
    
    var results = [Friend]() {
        didSet {
            // 刷新列表
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏标题
        title = "添加好友"
        
        // 获取焦点
        searchBar.becomeFirstResponder()
        
        
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
        return results.count
    }
    //
    /* 每行显示的内容
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchUserCell", forIndexPath: indexPath)

        cell.textLabel?.text = results[indexPath.row].username

        return cell
    }
 
    // MARK: UISearchBarDelegate
    /**
    按下取消按钮，清空内容
    */
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        results = []
        searchBar.resignFirstResponder()
    }
    /**
     按下键盘搜索按钮，探索内容
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchWithText(searchBar.text)
        searchBar.resignFirstResponder()
    }
    /**
     边输入边显示
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchWithText(searchText)
    }
    /**
     根据字符串搜索用户
     - parameter searchText: 传入的字符串
     */
    func searchWithText(searchText: String?) {
        if let text = searchText where !text.isEmpty {
            Http.queryForObjects(text, doneCloser: { [unowned self](objects, error) -> () in
                // 查到用户，赋值给 results
                self.results = objects.flatMap({ $0.friend  })
                })
        }
    }

    
    // MARK: - Navigation

    //
    /* 传当前行的用户给目的 ViewController 的 friend
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? ContactCardTableViewController {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)!
                destinationVC.friend = results[indexPath.row]
            }
        }
    }
    
    deinit {
        print("SearchUserTableViewController deinit")
        print("----------------------------------------------------------------------------------------")
    }


}
