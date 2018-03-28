//
//  ManageProjectViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/16.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class ManageProjectViewController: NSViewController, NSTouchBarDelegate {
        required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var mainFunc: MainFunctions
    init(dbName: String, username: String, password: String, isNew: Bool = false) {
        mainFunc = MainFunctions(databaseName: dbName)! // 创建主功能对象
        super.init(nibName: "ManageProjectViewController", bundle: Bundle.main)!
        do {
            if isNew { // 如果是新项目
                try mainFunc.initDatabase() // 建表
                try mainFunc.registUser(username: username, password: password, authority: 0) // 权限0为管理者权限
            }
        } catch {
            Swift.print("error")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDevicesList()
    }
    @IBOutlet weak var tableView: NSTableView!
    var tableSource: TableSource?
    private func loadDevicesList() {
        tableSource = DeviceTable(_tableView: tableView, _mainFunc: mainFunc)
        (tableSource as? DeviceTable)?.constituteButton = constituteButton
        constituteButton.isHidden = false
        tableSource?.alterButton = alterButton
        tableSource?.initAlterButton()
    }
    private func loadComponentList() {
        tableSource = ComponentTable(_tableView: tableView, _mainFunc: mainFunc)
        constituteButton.isHidden = true
        tableSource?.alterButton = alterButton
        tableSource?.initAlterButton()
    }
    private func loadFactoryList() {
        tableSource = FactoryTable(_tableView: tableView, _mainFunc: mainFunc)
        constituteButton.isHidden = true
        tableSource?.alterButton = alterButton
        tableSource?.initAlterButton()
    }
    private func loadConstituteList(deviceName: String) {
        titleSegment.selectedSegment = 1
        bar_titleSegment?.selectedSegment = 1
        tableSource = ConstituteTable(_tableView: tableView, _mainFunc: mainFunc, deviceName: deviceName)
        constituteButton.isHidden = true
        tableSource?.alterButton = alterButton
        tableSource?.initAlterButton()
    }
    private func loadProductList() {
        tableSource = ProductTable(_tableView: tableView, _mainFunc: mainFunc)
        constituteButton.isHidden = true
        tableSource?.alterButton = alterButton
        tableSource?.initAlterButton()
    }
    @IBAction func addButtonClick(_ sender: NSButton) {
        (tableView.delegate as? TableAssist)?.addButtonClick(sender)
    }
    @IBAction func minusButtonClick(_ sender: NSButton) {
        (tableView.delegate as? TableAssist)?.minusButtonClick(sender)
    }
    @IBAction func titleSegmentChange(_ sender: NSSegmentedControl) {
        titleSegment.selectedSegment = sender.selectedSegment
        bar_titleSegment?.selectedSegment = sender.selectedSegment
        switch sender.selectedSegment {
        case 0:
            loadDevicesList()
        case 1:
            break
        case 2:
            loadComponentList()
        case 3:
            loadFactoryList()
        case 4:
            loadProductList()
        default:
            break
        }
    }
    @IBOutlet weak var titleSegment: NSSegmentedControl!
    
    @IBAction func constituteClick(_ sender: NSButton) {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        let device = mainFunc.getDevices()?[row].name
        loadConstituteList(deviceName: device!)
    }
    @IBOutlet weak var constituteButton: NSButton!
    open var windowController: NSWindowController?
    @IBOutlet weak var alterButton: NSButton!
    @IBOutlet weak var toolsView: NSView!
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier("ManageProjectViewController.touchBar")
        touchBar.defaultItemIdentifiers = [NSTouchBarItemIdentifier("选择条"), NSTouchBarItemIdentifier("plus")]
        touchBar.delegate = self
        return touchBar
    }
    var bar_titleSegment: NSSegmentedControl?
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        if identifier == NSTouchBarItemIdentifier("选择条") {
            bar_titleSegment = NSSegmentedControl(labels: ["设备", "详细信息", "零件", "厂商", "供货"], trackingMode: .selectOne, target: self, action: #selector(titleSegmentChange(_:)))
            bar_titleSegment?.drawCell(NSCell(textCell: "设备"))
            bar_titleSegment?.setEnabled(false, forSegment: 1)
            touchBarItem.view = bar_titleSegment ?? NSView()
        } else if identifier == NSTouchBarItemIdentifier("plus") {
            touchBarItem.view = NSButton(title: "+", target: self, action: #selector(addButtonClick(_:)))
        }
        return touchBarItem
    }
}
