//
//  FileChangeChooseViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class FileChangeChooseViewController: DatabaseChooseViewController {

    override func confirmClicked(_ sender: NSButton) {
        if tableView.selectedRow == -1 {
            return
        }
        let selectedDbName = databaseArray![tableView.selectedRow]
        let fcViewController = FileChangeViewController(dbName: selectedDbName)
        let fcWindow = NSWindow(contentViewController: fcViewController)
        fcWindow.title = "更改或删除项目"
        let fcWindowController = FileChangeWindowController(window: fcWindow)
        fcViewController.windowController = fcWindowController
        fcWindowController.showWindow(nil)
        windowController?.close()
    }
    
}
