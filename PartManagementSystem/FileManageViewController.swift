//
//  FileManageViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class FileManageViewController: NSViewController {
    
    open var windowController: NSWindowController?
    init() {
        super.init(nibName: "FileManageViewController", bundle: Bundle.main)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func fileInClick(_ sender: NSButton) {
        let openPannel = NSOpenPanel()
        openPannel.allowsMultipleSelection = true
        openPannel.canChooseDirectories = true
        openPannel.canChooseFiles = true
        openPannel.allowedFileTypes = ["sqlite3"]
        openPannel.allowsOtherFileTypes = false
        if openPannel.runModal() == NSFileHandlingPanelOKButton {
            for url in openPannel.urls {
                if DBM.dbFilePath == nil {
                    try? DBM.initDbFilePath()
                }
                
                try? MainFunctions.copyFile(from: url.path, to: DBM.dbFilePath! + "/" + url.lastPathComponent)
            }
        }
    }
    @IBAction func fileOutClick(_ sender: NSButton) {
        let fmViewController = FileManageChooseViewController()
        let fmWindow = NSWindow(contentViewController: fmViewController)
        let fmWindowController = FileChooseWindowController(window: fmWindow)
        fmWindow.title = "选择要备份的项目"
        fmViewController.windowController = fmWindowController
        fmWindowController.showWindow(nil)
    }
}
