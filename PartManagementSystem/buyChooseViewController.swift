//
//  buyChooseViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class buyChooseViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var windowController: NSWindowController?
    var mainFunc: MainFunctions?
    init() {
        super.init(nibName: "buyChooseViewController", bundle: Bundle.main)!
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var databaseArray: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.action = #selector(tableViewSelected(_:))
        do {
            try DBM.initDbFilePath()
            databaseArray = try FileManager.default.contentsOfDirectory(atPath: DBM.dbFilePath!)
            databaseArray?.remove(at: (databaseArray?.index(where: { (fileName) -> Bool in
                return fileName.substring(to: fileName.index(fileName.startIndex, offsetBy: fileName.count - 8)) != ".sqlite3"
            }))!)
        } catch {
            return
        }
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return databaseArray?.count ?? 0
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var content = ""
        if tableColumn?.identifier == "工程" {
            let fileName = databaseArray![row]
            let dbName = fileName.substring(to: fileName.index(fileName.startIndex, offsetBy: fileName.count - 8))
            content = dbName
        }
        return NSTextField(labelWithString: content)
    }
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBAction func registButtonClick(_ sender: NSButton) {
        let registViewController = RegistViewController(dbName: databaseArray![tableView.selectedRow].substring(to: databaseArray![tableView.selectedRow].index(databaseArray![tableView.selectedRow].startIndex, offsetBy: databaseArray![tableView.selectedRow].count - 8)) )
        let registWindow = NSWindow(contentViewController: registViewController)
        let registWindowController = RegistWindowController(window: registWindow)
        registViewController.windowController = registWindowController
        registWindowController.showWindow(nil)
    }
    @IBAction func cancleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
    @IBAction func finishiButtonClick(_ sender: NSButton) {
        let check = mainFunc?.checkLogin(username: usernameField.stringValue, password: passwordField.stringValue, authority: 2)
        if usernameField.stringValue != "" && passwordField.stringValue != "" && check! {
            let bmViewController = buyMainViewController(dbName: selectedDbName!, username: usernameField.stringValue)
            let bmWindow = NSWindow(contentViewController: bmViewController)
            bmWindow.title = "选择需要下单的设备和详细配置"
            let bmWindowController = buyMainWindowController(window: bmWindow)
            bmViewController.windowController = bmWindowController
            bmWindowController.showWindow(nil)
            windowController?.close()
        } else {
            let alert = NSAlert()
            alert.messageText = "身份验证失败！"
            alert.messageText = "用户名或密码错误，或是用户权限不足。"
            alert.addButton(withTitle: "好的")
            alert.runModal()
        }
    }
    @IBOutlet weak var finishButton: NSButton!
    @IBOutlet weak var registButton: NSButton!
    var selectedDbName: String?
    @objc func tableViewSelected(_ sender: NSTableView) {
        let row = tableView.selectedRow
        if row == -1 {
            finishButton.isEnabled = false
            usernameField.isEnabled = false
            passwordField.isEnabled = false
            registButton.isEnabled = false
        } else {
            finishButton.isEnabled = true
            usernameField.isEnabled = true
            passwordField.isEnabled = true
            registButton.isEnabled = true
            selectedDbName = databaseArray?[row].substring(to: (databaseArray?[row].index((databaseArray?[row].startIndex)!, offsetBy: (databaseArray?[row].count)! - 8))!)
            mainFunc = MainFunctions(databaseName: selectedDbName!)
        }
    }
}
