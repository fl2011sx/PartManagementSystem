//
//  LoginViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/14.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa
import SQLite

class LoginViewController: NSViewController {

    @IBOutlet weak var proNameLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        proNameLabel.stringValue = dbName // 显示数据库名称
    }
    
    @IBOutlet var UsernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    var mainFunc: MainFunctions?
    @IBAction func loginBtnClick(_ sender: NSButton) {
        if (mainFunc?.checkLogin(username: UsernameTextField.stringValue, password: passwordTextField.stringValue, authority: 0))! {
            let manageProViewController = ManageProjectViewController(dbName: dbName, username: UsernameTextField.stringValue, password: passwordTextField.stringValue)
            let manageProWindow = NSWindow(contentViewController: manageProViewController)
            manageProWindow.title = "生产零件管理"
            let manageProWindowController = NSWindowController(window: manageProWindow)
            manageProViewController.windowController = manageProWindowController
            manageProWindowController.showWindow(nil)
            windowController?.close()
        } else {
            let alert = NSAlert()
            alert.messageText = "身份验证失败！"
            alert.informativeText = "用户名或密码错误，或是用户权限不足"
            alert.addButton(withTitle: "好的")
            alert.runModal()
        }
    }
    
    open var windowController: NSWindowController?
    open var dbName: String
    var database: DBM?
    init(dbName _db: String) {
        dbName = _db
        mainFunc = MainFunctions(databaseName: _db)
        super.init(nibName: "LoginViewController", bundle: Bundle.main)!
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
