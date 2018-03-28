//
//  FileChooseViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/14.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa
import SQLite

class FileChooseViewController: NSViewController, NSTouchBarDelegate {
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    open var windowController: NSWindowController?
    convenience init() {
        self.init(nibName: "FileChooseViewController", bundle: Bundle.main)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try DBM.initDbFilePath() // 初始化数据库文件路径
        } catch {
            
        }
    }
    
    // MARK:- Button Click Actions
    @IBAction func newProject(_ sender: NSButton) {
        let newProjectViewController = NewProjectViewController()
        let newProjectWindow = NSWindow(contentViewController: newProjectViewController)
        newProjectWindow.title = "新建项目"
        let newProjectWindowController = NewProjectWindowController(window: newProjectWindow)
        newProjectViewController.windowController = newProjectWindowController
        newProjectWindowController.showWindow(nil)
        windowController?.close()
    }
    @IBAction func openProject(_ sender: NSButton) {
        let databaseChooseController = DatabaseChooseViewController()
        let databaseChooseWindow = NSWindow(contentViewController: databaseChooseController)
        databaseChooseWindow.title = "打开项目"
        windowController?.close()
        windowController = DatabaseChooseWindowController(window: databaseChooseWindow)
        databaseChooseController.windowController = windowController
        windowController?.showWindow(self)
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier("FileChooseViewController.touchbar")
        touchBar.defaultItemIdentifiers = [NSTouchBarItemIdentifier("新建项目"), NSTouchBarItemIdentifier("打开项目")]
        touchBar.delegate = self
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        if identifier == NSTouchBarItemIdentifier("新建项目") {
            touchBarItem.view = NSButton(title: "新建项目", target: self, action: #selector(newProject(_:)))
        } else if identifier == NSTouchBarItemIdentifier("打开项目") {
           touchBarItem.view = NSButton(title: "打开项目", target: self, action: #selector(openProject(_:)))
        }
        return touchBarItem
    }
    
}
