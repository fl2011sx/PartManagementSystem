//
//  Tables.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/16.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

protocol TableAssist {
    func addButtonClick(_ sender: NSButton)
    func minusButtonClick(_ sender: NSButton)
}

class TableSource: NSObject, NSTableViewDataSource, NSTableViewDelegate, TableAssist {
    var tableView: NSTableView
    var mainFunc: MainFunctions
    required init(_tableView: NSTableView, _mainFunc: MainFunctions) {
        tableView = _tableView
        mainFunc = _mainFunc
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.action = #selector(tableViewSelected(_:))
        tableView.doubleAction = #selector(tableViewDoubleClicked(_:))
        initColumn()
    }
    
    var titles: [String] {
        return []
    }
    fileprivate func initColumn() {
        for column in tableView.tableColumns {
            tableView.removeTableColumn(column)
        }
        for title in titles {
            let column = NSTableColumn(identifier: title)
            column.minWidth = 50
            column.width = 150
            column.title = title
            tableView.addTableColumn(column)
        }
    }
    open func reloadData() {
        initColumn()
        tableView.reloadData()
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return NSView()
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    @objc func tableViewSelected(_ sender: NSTableView) { // 某一行被选中
        let row = sender.selectedRow
        if row == -1 {
            alterButton?.isEnabled = false
        } else {
            alterButton?.isEnabled = true
        }
    }
    @objc func tableViewDoubleClicked(_ sender: NSTableView) { // 某一行被双击
    }
    func addButtonClick(_ sender: NSButton) {
    }
    func minusButtonClick(_ sender: NSButton) {
    }
    func alterButtonClick(_ sender: NSButton) {
        tableViewDoubleClicked(tableView)
    }
    var alterButton: NSButton?
    open func initAlterButton() {
        alterButton?.target = self
        alterButton?.action = #selector(alterButtonClick(_:))
        alterButton?.isEnabled = false
    }
}

protocol TableSourceDelegate {
    
}

class DeviceTable: TableSource {
    
    override var titles: [String] {
        return ["名称", "属性"]
    }
    var devices: [(name: String, properties: [String])]
    required init(_tableView: NSTableView, _mainFunc: MainFunctions) {
        let tmp = _mainFunc.getDevices()
        devices = tmp ?? [("null", ["null"])]
        super.init(_tableView: _tableView, _mainFunc: _mainFunc)
    }
    override func reloadData() {
        let tmp = mainFunc.getDevices()
        devices = tmp ?? [("null", ["null"])]
        super.reloadData()
    }
    override func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var content = ""
        if tableColumn?.identifier == "名称" {
            content = devices[row].name
        } else if tableColumn?.identifier == "属性" {
            var isFirstProperty = true
            for pro in devices[row].properties {
                if !isFirstProperty {
                    content += ", "
                }
                isFirstProperty = false
                content += pro
            }
        }
        return NSTextField(labelWithString: content)
    }
    func updateDatabase(deviceName: String, properties: [String], isAdd: Bool = true) {
        do {
            for property in properties {
                try mainFunc.addDevice(name: deviceName, propertyName: property)
            }
        } catch {
            Swift.print("error")
        }
    }
    override func addButtonClick(_ sender: NSButton) {
        let addDeviceViewController = AddDeviceViewController(tableSource: self)
        let addDeviceWindow = NSWindow(contentViewController: addDeviceViewController)
        addDeviceWindow.title = "添加或更改设备"
        let addDeviceWindowController = AddWindowController(window: addDeviceWindow)
        addDeviceViewController.windowController = addDeviceWindowController
        addDeviceWindowController.showWindow(nil)
    }
    override func minusButtonClick(_ sender: NSButton) {
        let device = devices[tableView.selectedRow]
        do {
            try mainFunc.deleteDevice(name: device.name, propertyName: nil)
        } catch {
            Swift.print(error)
            return
        }
        var indexSet = IndexSet()
        indexSet.insert(tableView.selectedRow)
        tableView.removeRows(at: IndexSet(indexSet), withAnimation: .slideLeft)
    }
    override func tableViewDoubleClicked(_ sender: NSTableView) {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        let addDeviceViewController = AddDeviceViewController(tableSource: self, deviceName: devices[row].name, properties: devices[row].properties)
        let addDeviceWindow = NSWindow(contentViewController: addDeviceViewController)
        addDeviceWindow.title = "添加或更改设备"
        let addDeviceWindowController = AddWindowController(window: addDeviceWindow)
        addDeviceViewController.windowController = addDeviceWindowController
        addDeviceWindowController.showWindow(nil)
    }
    open var constituteButton: NSButton?
    override func tableViewSelected(_ sender: NSTableView) {
        super.tableViewSelected(sender)
        let row = tableView.selectedRow
        if row == -1 {
            constituteButton?.isEnabled = false
        } else {
            constituteButton?.isEnabled = true
        }
    }
}

class ComponentTable : TableSource {
    override var titles: [String] {
        return ["型号", "适用设备", "类型", "价钱", "库存"]
    }
    var components: [(model_id: String, deviceName: String, type: String, price: Double?, amount: Int?)]?
    required init(_tableView: NSTableView, _mainFunc: MainFunctions) {
        components = _mainFunc.getComponents()
        super.init(_tableView: _tableView, _mainFunc: _mainFunc)
    }
    override func numberOfRows(in tableView: NSTableView) -> Int {
        return (components?.count) ?? 0
    }
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var content = ""
        if tableColumn?.identifier == "型号" {
            content = (components?[row].model_id)!
        }  else if tableColumn?.identifier == "适用设备" {
            content = (components?[row].deviceName)!
        } else if tableColumn?.identifier == "类型" {
            content = (components?[row].type)!
        } else if tableColumn?.identifier == "价钱" {
            if components?[row].price == nil {
                content = ""
            } else {
                content = "\(components![row].price!)"
            }
        } else if tableColumn?.identifier == "库存" {
            if components?[row].amount == nil {
                content = ""
            } else {
                content = "\(components![row].amount!)"
            }
        }
        let cell = NSTextField(labelWithString: content)
        return cell
    }
    override func addButtonClick(_ sender: NSButton) {
        let addComponentViewController = AddComponentViewController(tableSource: self)
        let addComponentWindow = NSWindow(contentViewController: addComponentViewController)
        addComponentWindow.title = "添加或更改零件"
        let addComponentWindowController = AddWindowController(window: addComponentWindow)
        addComponentViewController.windowController = addComponentWindowController
        addComponentWindowController.showWindow(nil)
    }
    override func minusButtonClick(_ sender: NSButton) {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        do {
            try mainFunc.deleteComponent(model_id: components![row].model_id)
        } catch {
            return
        }
        var indexSet = IndexSet()
        indexSet.insert(row)
        tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
    }
    open func checkData(type: String) -> Bool {
        let pros = mainFunc.getDevicesAllProperties()
        if pros == nil {
            return false
        }
        for pro in pros! {
            if pro == type {
                return true
            }
        }
        return false
    }
    open func updateDatabase(model_id: String, newModel_id: String?, deviceName: String, type: String, price: Double?, amount: Int?, isAdd: Bool = true) {
        do {
            if isAdd {
                try mainFunc.addComponent(model_id: model_id, deviceName: deviceName, type: type, price: price, amount: amount)
            } else {
                try mainFunc.alterComponent(model_id: model_id, newModel_id: newModel_id!, deviceName: deviceName, type: type, price: price, amount: amount)
            }
        } catch {
        }
    }
    override func reloadData() {
        components = mainFunc.getComponents()
        super.reloadData()
    }
    override func tableViewDoubleClicked(_ sender: NSTableView) {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        let addComponentViewController = AddComponentViewController(tableSource: self, model_id: components![row].model_id, deviceName: components![row].deviceName, componentType: components![row].type, price: components![row].price, amount: components![row].amount)
        let addComponentWindow = NSWindow(contentViewController: addComponentViewController)
        addComponentWindow.title = "添加或更改零件"
        let addComponentWindowController = AddWindowController(window: addComponentWindow)
        addComponentViewController.windowController = addComponentWindowController
        addComponentWindowController.showWindow(nil)
    }
}

class FactoryTable : TableSource {
    override var titles: [String] {
        return ["厂家"]
    }
    var factoies: [String]
    required init(_tableView: NSTableView, _mainFunc: MainFunctions) {
        factoies = _mainFunc.getFactories() ?? [""]
        super.init(_tableView: _tableView, _mainFunc: _mainFunc)
    }
    override func reloadData() {
        factoies = mainFunc.getFactories() ?? [""]
        super.reloadData()
    }
    override func numberOfRows(in tableView: NSTableView) -> Int {
        return factoies.count
    }
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var content = ""
        if tableColumn?.identifier == "厂家" {
            content = factoies[row]
        }
        return NSTextField(labelWithString: content)
    }
    override func addButtonClick(_ sender: NSButton) {
        let addFactoryViewController = AddFactoryViewController(tableSource: self)
        let addFactoryWindow = NSWindow(contentViewController: addFactoryViewController)
        addFactoryWindow.title = "添加或更改厂商信息"
        let addFactoryWindowController = AddWindowController(window: addFactoryWindow)
        addFactoryViewController.windowController = addFactoryWindowController
        addFactoryWindowController.showWindow(nil)
    }
    override func minusButtonClick(_ sender: NSButton) {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        do {
            try mainFunc.deleteFactory(name: factoies[row])
        } catch {
            return
        }
        var indexSet = IndexSet()
        indexSet.insert(row)
        tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
    }
    open func updateDatabase(name: String, newName: String? = nil, isAdd: Bool = true) {
        do {
            if isAdd {
                try mainFunc.addFactory(name: name)
            } else {
                try mainFunc.alterFactory(name: name, newName: newName!)
            }
        } catch {}
    }
    override func tableViewDoubleClicked(_ sender: NSTableView) {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        let addFactoryViewController = AddFactoryViewController(tableSource: self, factoryName: factoies[row])
        let addFactoryWindow = NSWindow(contentViewController: addFactoryViewController)
        addFactoryWindow.title = "添加或更改厂商信息"
        let addFactoryWindowController = AddWindowController(window: addFactoryWindow)
        addFactoryViewController.windowController = addFactoryWindowController
        addFactoryWindowController.showWindow(nil)
    }
}

class ConstituteTable: TableSource {
    var real_titles: [String] = ["配置名称", "所属设备"]
    var deviceName: String
    var constitutes: [(configuration_name: String, component: [(component_type: String, model_id: String)])]
    init(_tableView: NSTableView, _mainFunc: MainFunctions, deviceName dn: String) {
        deviceName = dn
        constitutes = _mainFunc.getConstitute(device_name: deviceName) ?? [("", [])]
        super.init(_tableView: _tableView, _mainFunc: _mainFunc)
        for con in mainFunc.getDeviceProperties(name: deviceName)! {
            real_titles.append(con)
        }
        initColumn()
    }
    required init(_tableView: NSTableView, _mainFunc: MainFunctions) {
        fatalError("init(_tableView:_mainFunc:) has not been implemented")
    }
    override func initColumn() {
        for cloumn in tableView.tableColumns {
            tableView.removeTableColumn(cloumn)
        }
        for name in real_titles {
            let column = NSTableColumn(identifier: name)
            column.title = name
            tableView.addTableColumn(column)
        }
    }
    override func reloadData() {
        constitutes = mainFunc.getConstitute(device_name: deviceName) ?? [("", [])]
        super.reloadData()
        initColumn()
    }
    override func numberOfRows(in tableView: NSTableView) -> Int {
        return constitutes.count
    }
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var content = ""
        if tableColumn?.identifier == "配置名称" {
            content = constitutes[row].configuration_name
        } else if tableColumn?.identifier == "所属设备" {
            content = deviceName
        } else {
            let component = constitutes[row].component
            for com in component {
                if com.component_type == tableColumn?.identifier {
                    content = com.model_id
                    break
                }
            }
        }
        return NSTextField(labelWithString: content)
    }
    open func updateDatabase(configuration_name: String, device_name: String, component_type: String, component_id: String, isAdd: Bool = true) {
        do {
            if isAdd {
                try mainFunc.addConstitue(configuration_name: configuration_name, device_name: device_name, component_type: component_type, component_id: component_id)
            } else {
                try mainFunc.alterConstitute(configuration_name: configuration_name, device_name: device_name, component_type: component_type, component_id: component_id)
            }
        } catch {}
    }
    open func updateDatabase(configuration_name: String, newName: String) {
        do {
            try mainFunc.alterConstituteName(configuration_name: configuration_name, newName: newName)
        } catch {}
    }
    override func minusButtonClick(_ sender: NSButton) {
        let row = tableView.selectedRow
        Swift.print(row)
        if row == -1 {
            return
        }
        do {
            try mainFunc.deleteConstitute(configuration_name: constitutes[row].configuration_name)
        } catch {
            return
        }
        var indexSet = IndexSet()
        indexSet.insert(tableView.selectedRow)
        tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
    }
    override func tableViewDoubleClicked(_ sender: NSTableView) {
        let row = sender.selectedRow
        if row == -1 {
            return
        }
        let addConsViewController = AddConsitituteViewController(tableSource: self, config_name: constitutes[row].configuration_name, device_name: deviceName)
        let addConsWindow = NSWindow(contentViewController: addConsViewController)
        addConsWindow.title = "添加或更改设备组成"
        let addConsWindowController = AddWindowController(window: addConsWindow)
        addConsViewController.windowController = addConsWindowController
        addConsViewController.config_name.isEnabled = false
        addConsWindowController.showWindow(nil)
    }
    override func addButtonClick(_ sender: NSButton) {
        let addConsViewController = AddConsitituteViewController(tableSource: self)
        let addConsWindow = NSWindow(contentViewController: addConsViewController)
        addConsWindow.title = "添加或更改设备组成"
        let addConsWindowController = AddWindowController(window: addConsWindow)
        addConsViewController.windowController = addConsWindowController
        addConsWindowController.showWindow(nil)
    }
}

class ProductTable : TableSource {
    override var titles: [String] {
        return ["生产厂家", "零件型号"]
    }
    var products: [(factory_name: String, component_id: String)]?
    required init(_tableView: NSTableView, _mainFunc: MainFunctions) {
        products = _mainFunc.getProducts()
        super.init(_tableView: _tableView, _mainFunc: _mainFunc)
    }
    override func reloadData() {
        products = mainFunc.getProducts()
        super.reloadData()
    }
    override func numberOfRows(in tableView: NSTableView) -> Int {
        return products?.count ?? 0
    }
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var content = ""
        if tableColumn?.identifier == "生产厂家" {
            content = products?[row].factory_name ?? ""
        } else if tableColumn?.identifier == "零件型号" {
            content = products?[row].component_id ?? ""
        }
        return NSTextField(labelWithString: content)
    }
    func updateDatabase(factory_name: String, model_id: String) {
        do {
            try mainFunc.addProduct(factory_name: factory_name, component_id: model_id)
        } catch {}
    }
    func updateDatabase(factory_name: String, newName: String, model_id: String, newId: String) {
        do {
            try mainFunc.alterProduct(factory_name: factory_name, newName: newName, component_id: model_id, newId: newId)
        } catch {}
    }
    func check_data(factory_name: String, model_id: String) -> (isExistFactory: Bool, isExistComponent: Bool) {
        var result: (isExistFactory: Bool, isExistComponent: Bool) = (false, false)
        let components = mainFunc.getComponents()
        if components == nil {
            result.isExistComponent = false
        }
        for component in components! {
            if component.model_id == model_id {
                result.isExistComponent = true
                break
            }
        }
        let factoies = mainFunc.getFactories()
        if factoies == nil {
            result.isExistFactory = false
        }
        for factory in factoies! {
            if factory == factory_name {
                result.isExistFactory = true
                break
            }
        }
        return result
    }
    override func addButtonClick(_ sender: NSButton) {
        let addProductViewController = AddProductViewController(tableSource: self)
        let addProductWindow = NSWindow(contentViewController: addProductViewController)
        addProductWindow.title = "添加或更改生产信息"
        let addProductWindowController = AddWindowController(window: addProductWindow)
        addProductViewController.windowController = addProductWindowController
        addProductWindowController.showWindow(nil)
    }
    override func minusButtonClick(_ sender: NSButton) {
        do {
            try mainFunc.deleteProduct(factory_name: products![tableView.selectedRow].factory_name, component_id: products![tableView.selectedRow].component_id)
        } catch {
            return
        }
        var indexSet = IndexSet()
        indexSet.insert(tableView.selectedRow)
        tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
    }
    override func tableViewDoubleClicked(_ sender: NSTableView) {
        let addProductViewController = AddProductViewController(tableSource: self, factory_name: products![sender.selectedRow].factory_name, component_id: products![sender.selectedRow].component_id)
        let addProductWindow = NSWindow(contentViewController: addProductViewController)
        addProductWindow.title = "添加或更改生产信息"
        let addProductWindowController = AddWindowController(window: addProductWindow)
        addProductViewController.windowController = addProductWindowController
        addProductWindowController.showWindow(nil)
    }
}


