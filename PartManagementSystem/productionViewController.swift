//
//  productionViewController.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/20.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa

class productionViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var mainFunc: MainFunctions
    open var windowController: NSWindowController?
    init(dbName: String) {
        mainFunc = MainFunctions(databaseName: dbName)!
        super.init(nibName: "productionViewController", bundle: Bundle.main)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var purches: [(id: Int, time_point: Int?, username: String, component_id: String)]?
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.action = #selector(tableViewSelected(_:))
        purches = mainFunc.getPurchesMessages()
        tableView.reloadData()
    }
    @IBOutlet weak var tableView: NSTableView!
    func numberOfRows(in tableView: NSTableView) -> Int {
        return purches?.count ?? 0
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if purches == nil {
            return nil
        }
        var content = ""
        switch (tableColumn?.identifier)! {
        case "单号":
            content = "\(purches![row].id)"
        case "用户":
            content = purches![row].username
        case "零件型号":
            content = purches![row].component_id
        case "时间":
            let format = DateFormatter()
            format.dateFormat = "yyyy年MM月dd日 a h:mm:ss"
            let date = Date(timeIntervalSince1970: TimeInterval(purches![row].time_point ?? 0))
            content = format.string(from: date)
        default:
            break
        }
        return NSTextField(labelWithString: content)
    }
    @IBOutlet weak var deleteButton: NSButton!
    @IBAction func deleteButtonClick(_ sender: NSButton) {
        do {
            try mainFunc.deletePurchesMessage(id: purches![tableView.selectedRow].id)
        } catch {
            return
        }
        var indexSet = IndexSet()
        indexSet.insert(tableView.selectedRow)
        tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
        purches = mainFunc.getPurchesMessages()
        tableView.reloadData()
    }
    @objc func tableViewSelected(_ sender: NSTableView) {
        let row = sender.selectedRow
        if row == -1 {
            deleteButton.isEnabled = false
        } else {
            deleteButton.isEnabled = true
        }
    }
}
