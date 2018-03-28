//
//  AppDelegate.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/11.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa
import SQLite

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainViewController = LaunchpadViewController()
        let mainWindow = NSWindow(contentViewController: mainViewController)
        mainWindow.title = "生产零件管理系统"
        mainWindowController = MainWindowController(window: mainWindow)
        mainWindowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

