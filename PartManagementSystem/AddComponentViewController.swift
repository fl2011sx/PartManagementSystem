//
//  AddComponentViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/19.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class AddComponentViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let devices = tableSource.mainFunc.getDevices()
        type1.removeAllItems()
        type2.removeAllItems()
        for device in devices! {
            type1.addItem(withTitle: device.name)
        }
        type1Selected(type1)
        if isUpdate {
            type1.selectItem(withTitle: defaultValue!.deviceName)
            type2.selectItem(withTitle: defaultValue!.componentType)
            model_idField.stringValue = defaultValue!.model_id
            priceField.stringValue = defaultValue!.price != nil ? "\(defaultValue!.price!)" : ""
            amountField.stringValue = defaultValue!.amount != nil ? "\(defaultValue!.amount!)": ""
        }
    }
    @IBAction func type1Selected(_ sender: NSPopUpButton) {
        let device = sender.titleOfSelectedItem
        type2.removeAllItems()
        if device == nil {
            return
        }
        let pros = tableSource.mainFunc.getDeviceProperties(name: device!)
        type2.addItems(withTitles: pros!)
    }
    @IBOutlet weak var model_idField: NSTextField!
    @IBOutlet weak var priceField: NSTextField!
    @IBOutlet weak var amountField: NSTextField!
    
    open var windowController: NSWindowController?
    var tableSource: ComponentTable
    
    var isUpdate: Bool
    init(tableSource ts: ComponentTable) {
        tableSource = ts
        isUpdate = false
        super.init(nibName: "AddComponentViewController", bundle: Bundle.main)!
    }
    var defaultValue: (model_id: String, deviceName: String, componentType: String, price: Double?, amount: Int?)?
    convenience init(tableSource ts: ComponentTable, model_id: String, deviceName: String, componentType: String, price: Double?, amount: Int?) {
        self.init(tableSource: ts)
        isUpdate = true
        defaultValue = (model_id, deviceName, componentType, price, amount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancleBtnClick(_ sender: NSButton) {
        windowController?.close()
    }
    
    @IBAction func confirmBtnClick(_ sender: NSButton) {
        if model_idField.stringValue == "" {
            let alert = NSAlert()
            alert.messageText = "名称不能为空！"
            alert.addButton(withTitle: "好的")
            alert.runModal()
            return
        }
        if isUpdate {
            tableSource.updateDatabase(model_id: defaultValue!.model_id, newModel_id: model_idField.stringValue, deviceName: (type1.selectedItem?.title)!, type: (type2.selectedItem?.title)!, price: priceField.stringValue == "" ? nil : priceField.doubleValue, amount: amountField.stringValue == "" ? nil : amountField.integerValue, isAdd: false)
        } else {
            tableSource.updateDatabase(model_id: model_idField.stringValue, newModel_id: nil, deviceName: (type1.selectedItem?.title)!, type: (type2.selectedItem?.title)!, price: priceField.stringValue == "" ? nil : priceField.doubleValue, amount: amountField.stringValue == "" ? nil : amountField.integerValue)
        }
        tableSource.reloadData()
        windowController?.close()
    }
    @IBOutlet weak var type1: NSPopUpButton!
    @IBOutlet weak var type2: NSPopUpButton!
}
