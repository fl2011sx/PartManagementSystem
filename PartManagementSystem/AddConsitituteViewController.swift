//
//  AddConsitituteViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/19.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class AddConsitituteViewController: NSViewController {
    
    var tableSource: ConstituteTable
    open var windowController: NSWindowController?
    init(tableSource ts: ConstituteTable) {
        isUpdate = false
        tableSource = ts
        super.init(nibName: "AddConsitituteViewController", bundle: Bundle.main)!
    }
    var isUpdate: Bool
    var defalutConfig_name: String?
    var defaultDevice_name: String?
    convenience init(tableSource ts: ConstituteTable, config_name: String, device_name: String) {
        self.init(tableSource: ts)
        isUpdate = true
        defalutConfig_name = config_name
        defaultDevice_name = device_name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        component_type.removeAllItems()
        device_name.removeAllItems()
        let devices = tableSource.mainFunc.getDevices()
        if devices != nil {
            for device in devices! {
                device_name.addItem(withTitle: device.name)
            }
        }
        deviceSelected(device_name)
        if isUpdate {
            config_name.stringValue = defalutConfig_name!
            device_name.selectItem(withTitle: defaultDevice_name!)
            typeSelected(component_type)
        }
        typeSelected(component_type)
    }
    
    @IBOutlet weak var config_name: NSTextField!
    @IBOutlet weak var device_name: NSPopUpButton!
    @IBOutlet weak var component_ModelId: NSPopUpButton!
    
    @IBOutlet weak var component_type: NSPopUpButton!
    @IBOutlet weak var component_id: NSTextField!
    @IBAction func concleButtonClick(_ sender: NSButton) {
        windowController?.close()
        tableSource.reloadData()
    }
    @IBAction func saveButtonClick(_ sender: NSButton) {
        let device_name = self.device_name.selectedItem?.title
        let component_type = self.component_type.selectedItem?.title
        let comps = tableSource.mainFunc.getComponent(type: component_type!, deviceName: device_name!)
        var isFound = false
        if comps == nil || component_type == "" {
            let alert = NSAlert()
            alert.messageText = "零件类型错误！"
            alert.informativeText = "当前所选零件类型在零件表中不存在或零件表为空。"
            alert.addButton(withTitle: "好的")
            alert.runModal()
            return
        }
        for comp in comps! {
            if comp.model_id == component_ModelId.selectedItem?.title {
                isFound = true
            }
        }
        if !isFound {
            let alert = NSAlert()
            alert.messageText = "零件型号不存在！"
//            alert.informativeText = "零件表中不存在一个型号为\(component_ModelId.selectedItem?.title)的零件"
            alert.addButton(withTitle: "好的")
            alert.runModal()
            return
        }
        if isUpdate {
            tableSource.updateDatabase(configuration_name: defalutConfig_name!, device_name: device_name!, component_type: component_type!, component_id: (component_ModelId.selectedItem?.title)!, isAdd: false)
        } else {
            tableSource.updateDatabase(configuration_name: config_name.stringValue, device_name: device_name!, component_type: component_type!, component_id: (component_ModelId.selectedItem?.title)!)
        }
        let alert = NSAlert()
        alert.messageText = "保存成功！"
        alert.addButton(withTitle: "好的")
        alert.runModal()
    }
    @IBAction func deviceSelected(_ sender: NSPopUpButton) {
        let device = sender.selectedItem?.title
        let component_types = tableSource.mainFunc.getConstitute(device_name: device!)
        self.component_type.removeAllItems()
        if isUpdate {
            for component_type in component_types![0].component {
                self.component_type.addItem(withTitle: component_type.component_type)
            }
        } else {
            for component_type in tableSource.mainFunc.getDeviceProperties(name: device!)! {
                self.component_type.addItem(withTitle: component_type)
            }
        }
    }
    @IBAction func typeSelected(_ sender: NSPopUpButton) {
        let coms = tableSource.mainFunc.getComponent(type: (component_type.selectedItem?.title)!, deviceName: (device_name.selectedItem?.title)!)
        if coms == nil {
            return
        }
        component_ModelId.removeAllItems()
        for com in coms! {
            component_ModelId.addItem(withTitle: com.model_id)
        }
    }
}
