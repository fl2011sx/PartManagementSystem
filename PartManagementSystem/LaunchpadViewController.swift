//
//  LaunchpadViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/14.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa
import SQLite

class LaunchpadViewController: NSViewController, LoadButtonDelegate, NSTouchBarDelegate {
    
    init() {
        self.btnTargetDunctions = [String: (NSButton) -> ()]()
        super.init(nibName: nil, bundle: nil)!
        let lv = LaunchpadView(frame: NSRect(x: 0, y: 0, width: 960, height: 540), viewController: self, layoutScheme:.big)
        let sv = NSScrollView(frame: NSRect(x: 0, y: 0, width: 960, height: 540))
        sv.hasHorizontalScroller = true
        sv.hasHorizontalRuler = true
        sv.contentView.documentView = lv
        sv.contentView.scroll(to: NSPoint(x: 0, y: lv.frame.size.height - 540))
        self.view = sv
        // 初始化按钮点击函数
        initTargetDunctions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK:- 按钮点击事件相关
    func btnClick(_ sender: LoadButton) {
        var action: ((LoadButton) -> ())?
        let funcName = sender.targetFunctionName
        if sender.targetFunctionName == nil || funcName == nil || funcName == "" {
            action = btnTargetDunctions["default"]
        } else {
            action = btnTargetDunctions[funcName!]
        }
        action?(sender)
    }
    
    private var btnTargetDunctions: [String: (NSButton) -> ()]
    private func initTargetDunctions() {
        btnTargetDunctions["default"] = {(_: NSButton) in
            Swift.print("This button hasn't tied with any functions")
        }
        btnTargetDunctions["openFileChooseWindow"] = {(_: NSButton) in
            let fileChooseViewController = FileChooseViewController()
            let fileChooseWindow = NSWindow(contentViewController: fileChooseViewController)
            fileChooseWindow.title = "创建或打开项目"
            self.fileChooseWindowController = FileChooseWindowController(window: fileChooseWindow)
            fileChooseViewController.windowController = self.fileChooseWindowController
            self.fileChooseWindowController?.showWindow(self)
            do {
                try DBM.initDbFilePath()
            } catch {}
        }
        btnTargetDunctions["openBuyWindow"] = {(_: NSButton) in
            let _buyChooseViewController = buyChooseViewController()
            let buyChooseWindow = NSWindow(contentViewController: _buyChooseViewController)
            buyChooseWindow.title = "信息键入"
            let _buyChooseWindowController = buyChooseWindowController(window: buyChooseWindow)
            _buyChooseViewController.windowController = _buyChooseWindowController
            _buyChooseWindowController.showWindow(nil)
        }
        btnTargetDunctions["showPurches"] = {(_: NSButton) in
            let pcViewController = productionChooseViewController()
            let pcWindow = NSWindow(contentViewController: pcViewController)
            pcWindow.title = "选择工程"
            let pcWindowController = productionChooseWindowController(window: pcWindow)
            pcViewController.windowController = pcWindowController
            pcWindowController.showWindow(nil)
        }
        btnTargetDunctions["fileManage"] = {(_: NSButton) in
            let fmViewController = FileManageViewController()
            let fmWindow = NSWindow(contentViewController: fmViewController)
            fmWindow.title = "文件备份"
            let fmWindowController = FileManageWindowControler(window: fmWindow)
            fmViewController.windowController = fmWindowController
            fmWindowController.showWindow(nil)
        }
        btnTargetDunctions["manageFile"] = {(_: NSButton) in
            let fccViewController = FileChangeChooseViewController()
            let fccWindow = NSWindow(contentViewController: fccViewController)
            fccWindow.title = "选择需要更改或删除的项目"
            let fccWindowController = DatabaseChooseWindowController(window: fccWindow)
            fccViewController.windowController = fccWindowController
            fccWindowController.showWindow(nil)
        }
    }
    
    var fileChooseWindowController: FileChooseWindowController?
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier("LaunchpadViewController.touchBar")
        
        let btnAmount = (NSDictionary(contentsOfFile: Bundle.main.path(forResource: "LoadButton", ofType: "plist")!)?.count)!
        for i in 0..<btnAmount {
            touchBar.defaultItemIdentifiers.append(NSTouchBarItemIdentifier("btn\(i + 1)"))
        }
        touchBar.delegate = self
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: identifier)
        let path = Bundle.main.path(forResource: "LoadButton", ofType: "plist")
        if (path == nil) {
            return item
        }
        let settings = NSDictionary(contentsOfFile: path!)
        if (settings == nil) {
            return item
        }
        let btn = NSButton(title: (settings?.value(forKey: identifier.rawValue) as! NSDictionary).value(forKey: "name") as! String, target: self, action: #selector(barClick(_:)))
        btn.identifier = (settings?.value(forKey: identifier.rawValue) as! NSDictionary).value(forKey: "targetFunction") as? String
        item.view = btn
        return item
    }
    
    @objc func barClick(_ sender: NSButton) {
        btnTargetDunctions[sender.identifier!]!(sender)
    }
}
