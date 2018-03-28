//
//  AddFactoryViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/19.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class AddFactoryViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if isUpdate {
            nameField.stringValue = defaultName!
        }
    }
    
    var tableSource: FactoryTable
    init(tableSource ts: FactoryTable) {
        isUpdate = false
        tableSource = ts
        super.init(nibName: "AddFactoryViewController", bundle: Bundle.main)!
    }
    var isUpdate: Bool
    var defaultName: String?
    convenience init(tableSource ts: FactoryTable, factoryName: String) {
        self.init(tableSource: ts)
        isUpdate = true
        defaultName = factoryName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var windowController: NSWindowController?
    
    @IBOutlet weak var nameField: NSTextField!
    @IBAction func cancleBtnClick(_ sender: NSButton) {
        windowController?.close()
    }
    
    @IBAction func confirmBtnClick(_ sender: NSButton) {
        if nameField.stringValue == "" {
            let alert = NSAlert()
            alert.messageText = "名字不能为空！"
            alert.addButton(withTitle: "好的")
            alert.runModal()
            return
        }
        if isUpdate {
            tableSource.updateDatabase(name: defaultName!, newName: nameField.stringValue, isAdd: false)
        } else {
            tableSource.updateDatabase(name: nameField.stringValue)
        }
        tableSource.reloadData()
        windowController?.close()
    }
}
