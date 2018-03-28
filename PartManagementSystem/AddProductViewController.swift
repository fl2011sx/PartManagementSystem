//
//  AddProductViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class AddProductViewController: NSViewController {
    var tableSource: ProductTable

    init(tableSource ts: ProductTable) {
        tableSource = ts
        isUpdate = false
        super.init(nibName: "AddProductViewController", bundle: Bundle.main)!
    }
    var defaultFactory: String?
    var defaultComponent: String?
    var isUpdate: Bool
    convenience init(tableSource ts: ProductTable, factory_name: String, component_id: String) {
        self.init(tableSource: ts)
        isUpdate = true
        defaultFactory = factory_name
        defaultComponent = component_id
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open var windowController: NSWindowController?

    override func viewDidLoad() {
        super.viewDidLoad()
        factory.removeAllItems()
        component.removeAllItems()
        let factoies = tableSource.mainFunc.getFactories()
        let components = tableSource.mainFunc.getComponents()
        if factoies == nil || components == nil {
            return
        }
        for fac in factoies! {
            factory.addItem(withTitle: fac)
        }
        for comp in components! {
            component.addItem(withTitle: comp.model_id)
        }
        if isUpdate {
            factory.selectItem(withTitle: defaultFactory!)
            component.selectItem(withTitle: defaultComponent!)
        }
    }
    @IBOutlet weak var factory: NSPopUpButton!
    @IBOutlet weak var component: NSPopUpButton!
    
    @IBAction func confirmButtonClick(_ sender: NSButton) {
        if isUpdate {
            tableSource.updateDatabase(factory_name: defaultFactory!, newName: (factory.selectedItem?.title)!, model_id: defaultComponent!, newId: (component.selectedItem?.title)!)
        } else {
            tableSource.updateDatabase(factory_name: (factory.selectedItem?.title)!, model_id: (component.selectedItem?.title)!)
        }
        tableSource.reloadData()
        windowController?.close()
    }
    @IBAction func concleButtonClick(_ sender: NSButton) {
        windowController?.close()
    }
}
