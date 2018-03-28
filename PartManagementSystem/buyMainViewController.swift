//
//  buyMainViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class buyMainViewController: NSViewController {
    
    open var windowController: NSWindowController?
    var dbName: String
    var mainFunc: MainFunctions
    var username: String
    init(dbName db: String, username un: String) {
        username = un
        dbName = db
        mainFunc = MainFunctions(databaseName: dbName)!
        super.init(nibName: "buyMainViewController", bundle: Bundle.main)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var tableSource: ConstituteTable?
    override func viewDidLoad() {
        super.viewDidLoad()
        devices.removeAllItems()
        let devs = mainFunc.getDevices()
        if devs == nil {
            return
        }
        for dev in devs! {
            devices.addItem(withTitle: dev.name)
        }
        reload()
    }
    private func reload() {
        for cloumn in tableView.tableColumns {
            tableView.removeTableColumn(cloumn)
        }
        tableSource = ConstituteTable(_tableView: tableView, _mainFunc: mainFunc, deviceName: (devices.selectedItem?.title)!)
        tableView.target = self
        tableView.action = #selector(tableViewSelected(_:))
        tableView.reloadData()
    }
    @IBOutlet weak var devices: NSPopUpButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var confirmButton: NSButton!
    
    @IBAction func confirmButtonClick(_ sender: NSButton) {
        
        let config_name = mainFunc.getConstitute(device_name: (devices.selectedItem?.title)!)?[tableView.selectedRow].configuration_name
        do {
            try mainFunc.addPurchesMessage(startId: nil, time_point: Int(NSDate().timeIntervalSince1970), username: username, configuration_name: config_name!)
        } catch {
            return
        }
        let alert = NSAlert()
        alert.messageText = "下单已完成！"
        alert.addButton(withTitle: "好的")
        alert.runModal()
//        windowController?.close()
    }
    @IBAction func cancleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
    @IBAction func deviceSelected(_ sender: NSPopUpButton) {
        reload()
    }
    @objc func tableViewSelected(_ sender: NSTableView) {
        let row = tableView.selectedRow
        if row == -1 {
            confirmButton.isEnabled = false
        } else {
            confirmButton.isEnabled = true
        }
    }
}
