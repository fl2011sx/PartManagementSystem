//
//  AddDeviceViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/16.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class AddDeviceViewController: NSViewController {
    var isUpdate: Bool
    init(tableSource ts: DeviceTable) {
        tableSource = ts
        isUpdate = false
        super.init(nibName: "AddDeviceViewController", bundle: Bundle.main)!
    }
    
    var defaultDeviceName: String?
    var defaultProperties: [String]?
    convenience init(tableSource ts: DeviceTable, deviceName name: String, properties: [String]) {
        self.init(tableSource: ts)
        isUpdate = true
        defaultDeviceName = name
        defaultProperties = properties
    }
    
    @IBOutlet weak var clearButton: NSButton!
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        deviceNameLabel.stringValue = defaultDeviceName ?? ""
        if defaultProperties != nil {
            for pro in defaultProperties! {
                if typesLabel.stringValue != "" {
                    typesLabel.stringValue += ", "
                }
                typesLabel.stringValue += pro
            }
        }
    }
    
    open var windowController: NSWindowController?
    open var tableSource: DeviceTable
    
    @IBOutlet weak var typesLabel: NSTextField!
    @IBOutlet weak var deviceNameLabel: NSTextField!
    @IBOutlet weak var newTypeLabel: NSTextField!
    @IBAction func cancleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
    @IBAction func confirmButtonClick(_ sender: NSButton) {
        if deviceNameLabel.stringValue == "" {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "名称不能为空"
            alert.runModal()
        } else if properties == nil {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.messageText = "属性不能为空"
            alert.runModal()
        } else {
            tableSource.updateDatabase(deviceName: deviceNameLabel.stringValue, properties: properties!, isAdd: !isUpdate)
            windowController?.close()
        }
        
        tableSource.reloadData()
    }
    var properties: [String]?
    @IBAction func addButtonClick(_ sender: NSButton) {
        if newTypeLabel.stringValue == "" {
            return
        }
        if properties == nil {
            properties = [String]()
        }
        if typesLabel.stringValue != "" {
            typesLabel.stringValue += ", "
        }
        typesLabel.stringValue += newTypeLabel.stringValue
        properties?.append(newTypeLabel.stringValue)
        newTypeLabel.stringValue = ""
    }
    @IBAction func clearBtnClick(_ sender: NSButton) {
        if isUpdate {
            properties = defaultProperties
            typesLabel.stringValue = ""
            for pro in defaultProperties! {
                if typesLabel.stringValue != "" {
                    typesLabel.stringValue += ", "
                }
                typesLabel.stringValue += pro
            }
        } else {
            properties?.removeAll()
            typesLabel.stringValue = ""
        }
    }
}
