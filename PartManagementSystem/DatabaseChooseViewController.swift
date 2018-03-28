//
//  DatabaseChooseViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/14.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class DatabaseChooseViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    open var windowController: NSWindowController?
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "DatabaseChooseViewController", bundle: Bundle.main)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            // 初始化数据库路径
            try DBM.initDbFilePath()
            databaseArray = try FileManager.default.contentsOfDirectory(atPath: DBM.dbFilePath!)
            databaseArray?.remove(at: (databaseArray?.index(where: { (fileName) -> Bool in
                return fileName.substring(to: fileName.index(fileName.startIndex, offsetBy: fileName.count - 8)) != ".sqlite3"
            }))!)
        } catch {
            
        }
        // 设置列表数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    var databaseArray: [String]? // 用于保存数据库文件列表
    // MARK:- 数据源方法
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (databaseArray?.count)!
    }
    // MARK:- 代理方法
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell: NSTextField?
        if tableColumn?.identifier == "column0" {
            let fileName = databaseArray![row]
            let dbName = fileName.substring(to: fileName.index(fileName.startIndex, offsetBy: fileName.count - 8))
            cell = NSTextField(labelWithString: dbName)
        }
        return cell
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    // MARK:-
    @IBOutlet weak var confirmButton: NSButton! // 确定按钮
    @IBAction func tableViewSelected(_ sender: NSTableView) { // 某一行被选中
        if tableView.selectedRow != -1 {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
    @IBAction func tableViewDoubleClicked(_ sender: NSTableView) { // 某一行被双击
        confirmClicked(confirmButton)
    }
    @IBAction func confirmClicked(_ sender: NSButton) {
        if tableView.selectedRow == -1 {
            return
        }
        var selectedDbName = (databaseArray?[tableView.selectedRow])
        if tableView.selectedRow != -1 {
            selectedDbName = selectedDbName?.substring(to: (selectedDbName?.index((selectedDbName?.startIndex)!, offsetBy: (selectedDbName?.count)! - 8))!)
        }
        // 将数据带至登录界面
        let loginViewController = LoginViewController(dbName: selectedDbName!)
        let loginWindow = NSWindow(contentViewController: loginViewController)
        loginWindow.title = "身份验证"
        let loginWindowController = LoginWindowController(window: loginWindow)
        loginViewController.windowController = loginWindowController
        windowController?.close()
        loginWindowController.showWindow(self)
    }
    @IBAction func cancleClicked(_ sender: NSButton) {
        windowController?.close()
    }
}
