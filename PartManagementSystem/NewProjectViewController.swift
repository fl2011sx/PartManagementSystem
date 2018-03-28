//
//  NewProjectViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/16.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class NewProjectViewController: NSViewController, NSTouchBarDelegate {
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience init() {
        self.init(nibName: "NewProjectViewController", bundle: Bundle.main)!
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var windowController: NSWindowController?

    @IBOutlet weak var projectNameField: NSTextField!
    @IBOutlet weak var usernameFiled: NSTextField!
    @IBOutlet weak var passwordField: NSTextField!

    @IBAction func cancleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
    @IBAction func nextStepButtonClick(_ sender: NSButton) {
        let proName = projectNameField.stringValue
        let username = usernameFiled.stringValue
        let password = passwordField.stringValue
        
        if MainFunctions.isExists(dbName: proName) {
            let alert = NSAlert()
            alert.messageText = "工程重名"
            alert.informativeText = "在工程项目中已经拥有一个名为\"\(proName)\"的工程了！"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        if username == "" {
            let alert = NSAlert()
            alert.messageText = "用户名为空"
            alert.informativeText = "初始管理账户的用户名不能为空！"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }
        
        
        
        let manageProjectViewController = ManageProjectViewController(dbName: proName, username: username, password: password, isNew: true)
        let manageProjectWindow = NSWindow(contentViewController: manageProjectViewController)
        manageProjectWindow.title = "生产零件管理"
        let manageProjectWindowController = ManageProjectWindowController(window: manageProjectWindow)
        manageProjectViewController.windowController = manageProjectWindowController
        manageProjectWindowController.showWindow(nil)
        windowController?.close()
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier("NewProjectViewController.touchbar")
        touchBar.defaultItemIdentifiers = [NSTouchBarItemIdentifier("取消"), NSTouchBarItemIdentifier("下一步")]
        touchBar.delegate = self
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        if identifier == NSTouchBarItemIdentifier("取消") {
            touchBarItem.view = NSButton(title: "取消", target: self, action: #selector(cancleButtonClick(_:)))
        } else if identifier == NSTouchBarItemIdentifier("下一步") {
            touchBarItem.view = NSButton(title: "下一步", target: self, action: #selector(nextStepButtonClick(_:)))
        }
        return touchBarItem
    }
}
