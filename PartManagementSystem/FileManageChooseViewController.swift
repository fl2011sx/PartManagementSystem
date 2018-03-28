//
//  FileManageChooseViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class FileManageChooseViewController: DatabaseChooseViewController {
    override func confirmClicked(_ sender: NSButton) {
        if tableView.selectedRow == -1 {
            return
        }
        var selectedDbName = (databaseArray?[tableView.selectedRow])
        if tableView.selectedRow != -1 {
            selectedDbName = selectedDbName?.substring(to: (selectedDbName?.index((selectedDbName?.startIndex)!, offsetBy: (selectedDbName?.count)! - 8))!)
        }
        let pannal = NSSavePanel()
        pannal.nameFieldStringValue = selectedDbName!
        pannal.message = "请选择要导出文件的路径"
        pannal.allowedFileTypes = ["sqlite3"]
        pannal.isExtensionHidden = true
        pannal.canCreateDirectories = true
        let saveWindow = windowController?.window ?? NSWindow()
        pannal.beginSheetModal(for: saveWindow) { (result) in
            if result == NSFileHandlingPanelOKButton {
                try! MainFunctions.copyFile(from: DBM.dbFilePath! + "/\(selectedDbName!).sqlite3", to: (pannal.url?.path)!)
                self.windowController?.close()
            }
        }
    }
}
