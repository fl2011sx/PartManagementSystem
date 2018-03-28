
//
//  FileChangeViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class FileChangeViewController: NSViewController {
    var dbName: String
    var windowController: NSWindowController?
    init(dbName db: String) {
        dbName = db
        super.init(nibName: "FileChangeViewController", bundle: Bundle.main)!
        try? DBM.initDbFilePath()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nameFiled.stringValue = dbName.substring(to: dbName.index(dbName.startIndex, offsetBy: dbName.count - 8))
    }
    @IBOutlet weak var nameFiled: NSTextField!
    @IBAction func deleteButtonClick(_ sender: NSButton) {
        let path = DBM.dbFilePath! + "/" + dbName
        try? FileManager.default.removeItem(atPath: path)
        let alert = NSAlert()
        alert.messageText = "删除成功！"
        alert.addButton(withTitle: "好的")
        alert.runModal()
        windowController?.close()
    }
    @IBAction func finishButtonClick(_ sender: NSButton) {
        let path = DBM.dbFilePath! + "/" + dbName
        try? FileManager.default.moveItem(atPath: path, toPath: DBM.dbFilePath! + "/" + nameFiled.stringValue + ".sqlite3")
        let alert = NSAlert()
        alert.messageText = "更改完毕！"
        alert.addButton(withTitle: "好的")
        alert.runModal()
        windowController?.close()
    }
    @IBAction func cancleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
    
}
