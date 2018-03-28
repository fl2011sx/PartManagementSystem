//
//  RegistViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class RegistViewController: NSViewController {
    
    open var windowController: NSWindowController?
    var mainFunc: MainFunctions
    init(dbName db: String) {
        mainFunc = MainFunctions(databaseName: db)!
        super.init(nibName: "RegistViewController", bundle: Bundle.main)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordFiled: NSSecureTextField!
    
    @IBOutlet weak var passwordAgainFiled: NSSecureTextField!
    @IBAction func confirmButtonClick(_ sender: NSButton) {
        if !mainFunc.checkReigst(username: usernameField.stringValue) {
            let alert = NSAlert()
            alert.messageText = "用户名\"\(usernameField.stringValue)\"已被注册"
            alert.addButton(withTitle: "好的")
            alert.runModal()
            return
        } else if passwordFiled.stringValue != passwordAgainFiled.stringValue {
            let alert = NSAlert()
            alert.messageText = "两次密码不一致！"
            alert.addButton(withTitle: "好的")
            alert.runModal()
            return
        }
        do {
            try mainFunc.registUser(username: usernameField.stringValue, password: passwordFiled.stringValue, authority: 2) // 权限2为客户权限
        } catch {
            return
        }
        windowController?.close()
    }
    @IBAction func cancleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
}
