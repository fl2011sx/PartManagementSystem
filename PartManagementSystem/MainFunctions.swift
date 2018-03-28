//
//  MainFunctions.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/15.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import Cocoa
import SQLite

class MainFunctions_Basic : NSObject {
    var database: DBM?
    
    init?(databaseName: String) {
        super.init()
        do {
            database = try DBM(databaseName)
        } catch {
            database = nil
        }
    }
    // 错误信息表
    enum MainFunctionsError: Error {
        case selectError
        case insertError
        case deleteError
        case createTableError
        case alterTableError
    }
    
    // MARK:- 用户相关
    // 建立用户表
    open func createTable_user() throws {
        do {
            try database?.createTable(tableName: "user", tableProperty: { (tb) in
                tb.column(Expression<String>("username"), primaryKey: true)
                tb.column(Expression<String>("password"))
                tb.column(Expression<Int>("authority"), defaultValue: 0)
            })
            database?.createIndex(tableName: "user", column: Expression<String>("username"))
        } catch {
            throw MainFunctionsError.createTableError
        }
    }
    // 核对登录信息
    open func checkLogin(username: String, password: String, authority: Int) -> Bool {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "user")?.filter(Expression<String>("username") == username && Expression<String>("password") == password && Expression<Int>("authority") <= authority))
        if rows == nil {
            return false
        }
        for _ in rows! {
            return true
        }
        return false
    }
    open func checkReigst(username: String) -> Bool {
        let rows = database?.getRowBySelect(database?.select(tableName: "user", column: Expression<String>("username"))?.filter(Expression<String>("username") == username))
        if rows == nil {
            return true
        }
        for _ in rows! {
            return false
        }
        return true
    }
    // 注册用户
    open func registUser(username: String, password: String, authority: Int = 0) throws {
        do {
            try database?.insertTable(tableName: "user", values: Expression<String>("username") <- username, Expression<String>("Password") <- password, Expression<Int>("authority") <- authority)
        // INSERT INTO user SET username=***, password=***, autority=***
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    // 更改用户信息
    open func alterUser(username: String, newUsername: String? = nil, newPassword: String?, newAuthority: Int? = nil) throws {
        do {
            if newUsername != nil {
                try database?.updateTable(tableName: "user", values: Expression<String>("username") <- newUsername!)
            }
            if newPassword != nil {
                try database?.updateTable(tableName: "user", values: Expression<String>("password") <- newPassword!)
            }
            if newAuthority != nil {
                try database?.updateTable(tableName: "user", values: Expression<Int>("authority") <- newAuthority!)
            }
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    // 删除用户
    open func deleteUser(username: String) throws {
        do {
            try database?.drop(tableName: "user", column: Expression<String>("username") == username)
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    // MARK:- 设备相关
    // 建立设备表
    open func createTable_device() throws {
        do {
            try database?.createTable(tableName: "device", tableProperty: { (tb) in
                tb.column(Expression<String>("name"))
                tb.column(Expression<String>("property"))
                tb.primaryKey(Expression<String>("name"), Expression<String>("property"))
            })
            database?.createIndex(tableName: "device", column: Expression<String>("name"))
        } catch {
            throw MainFunctionsError.createTableError
        }
    }
    // 获得设备信息

    open func getDeviceProperties(name: String) -> [String]? {
        let rows = database?.getRowBySelect(database?.select(tableName: "device", column: Expression<String>("property"))?.filter(Expression<String>("name") == name))
        if rows == nil {
            return nil
        }
        var result = [String]()
        for row in rows! {
            result.append(row.get(Expression<String>("property")))
        }
        return result
    }
    open func getDevices() -> [(name: String, properties: [String])]? {
        let rows = database?.getRowBySelect(database?.select(tableName: "device", column: Expression<String>("name")))
        if rows == nil {
            return nil
        }
        var result = [(name: String, properties: [String])]()
        for row in rows! {
            let name = row.get(Expression<String>("name"))
            result.append((name, getDeviceProperties(name: name)!))
        }
        return result
    }
    open func getDevicesAllProperties() -> [String]? {
        let rows = database?.getRowBySelect(database?.select(tableName: "device", column: Expression<String>("property")))
        if rows == nil {
            return nil
        }
        var result = [String]()
        for row in rows! {
            result.append(row.get(Expression<String>("property")))
        }
        return result
    }
    // 添加设备信息
    open func addDevice(name deviceName: String, propertyName: String) throws {
        do {
            try database?.insertTable(tableName: "device", values: Expression<String>("name") <- deviceName, Expression<String>("property") <- propertyName)
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    // 删除设备
    open func deleteDevice(name deviceName: String, propertyName: String?) throws {
        do {
            if propertyName == nil {
                try database?.drop(tableName: "device", column: Expression<String>("name") == deviceName)
//                try database?.customSQLRun("DELETE FROM device WHERE name=\"\(deviceName)\"")
            } else {
                try database?.drop(tableName: "device", column: Expression<String>("name") == deviceName && Expression<String>("property") == propertyName!)
            }
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    // 更改设备信息
    open func alterDevice(deviceName: String, propertyName: String, newValue: String) throws {
        do {
            try database?.updateTable(tableName: "device", filter: Expression<String>("name") == deviceName && Expression<String>("property") == propertyName, values: Expression<String>("property") <- newValue)
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    // MARK:- 购买设备相关
    // 创建购买表格
    open func createTable_purches() throws {
        do {
            try database?.createTable(tableName: "purches", tableProperty: { (tb) in
                tb.column(Expression<Int>("id"), primaryKey: true)
                tb.column(Expression<Int?>("time_point"))
                tb.column(Expression<String>("username"))
                tb.column(Expression<String>("component_id"))
                tb.foreignKey(Expression<String>("username"), references: Table("user"), Expression<String>("username"), update: .cascade, delete: .cascade)
                tb.foreignKey(Expression<String>("component_id"), references: Table("component"), Expression<String>("model_id"), update: .cascade, delete: .cascade)
            })
            database?.createIndex(tableName: "purches", column: Expression<Int>("id"))
            try database?.customSQLRun(
                "CREATE TRIGGER afterReducePurchesId\n" +
                "AFTER DELETE ON purches\n" +
                "BEGIN\n" +
                "UPDATE purches SET id = id - 1 WHERE id in(SELECT id from purches WHERE id>old.id);\n" +
                "END;"
            ) // 触发器功能：当订单删除后，后面的订单顺序依次补齐
        } catch {
            throw MainFunctionsError.createTableError
        }
    }
    // 增加购买信息
    open func addPurchesMessage(id: Int?, time_point: Int? = nil, username: String, component_id: String) throws {
        do {
            if id == nil {
                try database?.insertTable(tableName: "purches", values:  Expression<String>("username") <- username, Expression<String>("component_id") <- component_id, Expression<Int?>("time_point") <- time_point)
            } else {
                try database?.insertTable(tableName: "purches", values: Expression<Int>("id") <- id!, Expression<String>("username") <- username, Expression<String>("component_id") <- component_id, Expression<Int?>("time_point") <- time_point)
            }
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    open func addPurchesMessage(startId: Int? = nil, time_point: Int? = nil, username: String,configuration_name: String) throws {
        do {
            let constitutes = getConstituteForComponents(configuration_name: configuration_name)
            if constitutes == nil {
                return
            }
            if startId != nil {
                var id = startId!
                for con in constitutes! {
                    try database?.insertTable(tableName: "purches", values: Expression<Int>("id") <- id, Expression<String>("username") <- username, Expression<String>("component_id") <- con, Expression<Int?>("time_point") <- time_point)
                    id += 1
                }
            } else {
                for con in constitutes! {
                    try database?.insertTable(tableName: "purches", values: Expression<String>("username") <- username, Expression<String>("component_id") <- con, Expression<Int?>("time_point") <- time_point)
                }
            }
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    // 查询购买信息
    open func getPurchesMessages() -> [(id: Int, time_point: Int?, username: String, component_id: String)]? {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "purches"))
        if rows == nil {
            return nil
        }
        var results = [(id: Int, time_point: Int?, username: String, component_id: String)]()
        for row in rows! {
            let result = (row.get(Expression<Int>("id")), row.get(Expression<Int?>("time_point")), row.get(Expression<String>("username")), row.get(Expression<String>("component_id")))
            results.append(result)
        }
        return results
    }
    open func getPurchesMessage(username: String) -> [(id: Int, time_point: Int?, username: String, component_id: String)] {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "purches")?.filter(Expression<String>("username") == username))
        if rows == nil {
            return []
        }
        var results = [(id: Int, time_point: Int?, username: String, component_id: String)]()
        for row in rows! {
            let result = (row.get(Expression<Int>("id")), row.get(Expression<Int?>("time_point")), row.get(Expression<String>("username")), row.get(Expression<String>("component_id")))
            results.append(result)
        }
        return results
    }
    open func getPurchesMessage(time_point: Int) -> [(id: Int, time_point: Int?, username: String, device_name: String)] {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "purches")?.filter(Expression<Int>("time_point") == time_point))
        if rows == nil {
            return []
        }
        var results = [(id: Int, time_point: Int?, username: String, device_name: String)]()
        for row in rows! {
            let result = (row.get(Expression<Int>("id")), row.get(Expression<Int?>("time_point")), row.get(Expression<String>("username")), row.get(Expression<String>("device_name")))
            results.append(result)
        }
        return results
    }
    // 删除购买信息
    open func deletePurchesMessage(id: Int) throws {
        do {
            try database?.drop(tableName: "purches", column: Expression<Int>("id") == id)
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    
    // MARK:- 零件相关
    // 创建零件表格
    open func createTabel_component() throws {
        do {
            try database?.createTable(tableName: "component", tableProperty: { (tb) in
                tb.column(Expression<String>("model_id"), primaryKey: true)
                tb.column(Expression<String>("forDevice"))
                tb.column(Expression<String>("type"))
                tb.column(Expression<Double?>("price"))
                tb.column(Expression<Int?>("amount"))
                tb.foreignKey((Expression<String>("forDevice"), Expression<String>("type")), references: Table("device"),( Expression<String>("name"), Expression<String>("property")), update: .cascade, delete: .cascade)
            })
            // 为零件表的model_id数据项建立索引
            database?.createIndex(tableName: "component", column: Expression<String>("model_id"))
        } catch {
            throw MainFunctionsError.createTableError
        }
    }
    // 添加零件
    open func addComponent(model_id: String, deviceName forDevice: String, type: String, price: Double? = nil, amount: Int? = nil) throws {
        do {
            try database?.insertTable(tableName: "component", values: Expression<String>("model_id") <- model_id, Expression<String>("forDevice") <- forDevice, Expression<String>("type") <- type, Expression<Double?>("price") <- price, Expression<Int?>("amount") <- amount)
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    // 获取零件信息
    open func getComponents() -> [(model_id: String, deviceName: String, type: String, price: Double?, amount: Int?)]? {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "component"))
        if rows == nil {
            return nil
        }
        var result:[(model_id: String, deviceName: String, type: String, price: Double?, amount: Int?)]  = []
        for row in rows! {
            let model_id = row.get(Expression<String>("model_id"))
            let deviceName = row.get(Expression<String>("forDevice"))
            let type = row.get(Expression<String>("type"))
            let price = row.get(Expression<Double?>("price"))
            let amount = row.get(Expression<Int?>("amount"))
            result.append((model_id, deviceName, type, price, amount))
        }
        return result
    }
    open func getComponent(type: String, deviceName: String) -> [(model_id: String, deviceName: String, type: String, price: Double?, amount: Int?)]? {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "component")?.filter(Expression<String>("type") == type && Expression<String>("forDevice") == deviceName))
        if rows == nil {
            return nil
        }
        var result:[(model_id: String, deviceName: String, type: String, price: Double?, amount: Int?)]  = []
        for row in rows! {
            let model_id = row.get(Expression<String>("model_id"))
            let deviceName = row.get(Expression<String>("forDevice"))
            let type = row.get(Expression<String>("type"))
            let price = row.get(Expression<Double?>("price"))
            let amount = row.get(Expression<Int?>("amount"))
            result.append((model_id, deviceName, type, price, amount))
        }
        return result
    }
    // 更改零件信息
    open func alterComponent(model_id: String, newModel_id: String, deviceName forDevice: String,  type: String, price: Double?, amount: Int?) throws {
        do {
           try database?.updateTable(tableName: "component", filter: Expression<String>("model_id") == model_id, values: Expression<String>("model_id") <- newModel_id, Expression<String>("forDevice") <- forDevice, Expression<String>("type") <- type, Expression<Double?>("price") <- price, Expression<Int?>("amount") <- amount)
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    // 删除零件
    open func deleteComponent(model_id: String) throws {
        do {
            try database?.drop(tableName: "component", column: Expression<String>("model_id") == model_id)
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    
    // MARK:- 组成相关
    // 创建组成表格
    open func createTable_constitute() throws {
        do {
            try database?.createTable(tableName: "constitute", tableProperty: { (tb) in
                tb.column(Expression<String>("configuration_name"))
                tb.column(Expression<String>("device_name"))
                tb.column(Expression<String>("component_type"))
                tb.column(Expression<String>("component_id"))
                tb.foreignKey((Expression<String>("device_name"), Expression<String>("component_type")), references: Table("device"), (Expression<String>("name"), Expression<String>("property")), update: .cascade, delete: .cascade)
                tb.foreignKey(Expression<String>("component_id"), references: Table("component"), Expression<String>("model_id"), update: .cascade, delete: .cascade)
                tb.primaryKey(Expression<String>("configuration_name"), Expression<String>("device_name"), Expression<String>("component_type"))
            })
            // 为组成表的component_id建立索引
            database?.createIndex(tableName: "constitute", column: Expression<String>("component_id"))
        } catch {
            throw MainFunctionsError.createTableError
        }
    }
    // 添加设备组成
    open func addConstitue(configuration_name: String, device_name: String, component_type: String, component_id: String) throws {
        do {
            try database?.insertTable(tableName: "constitute", values: Expression<String>("configuration_name") <- configuration_name, Expression<String>("device_name") <- device_name, Expression<String>("component_type") <- component_type, Expression<String>("component_id") <- component_id)
        } catch {
            throw MainFunctionsError.insertError
        }
    }

    // 更改设备组成
    open func alterConstitute(configuration_name: String, device_name: String, component_type: String, component_id: String) throws {
        do {
            try database?.updateTable(tableName: "constitute", filter: Expression<String>("configuration_name") == configuration_name && Expression<String>("device_name") == device_name && Expression<String>("component_type") == component_type, values: Expression<String>("component_id") <- component_id)
            
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    open func alterConstituteName(configuration_name: String, newName: String) throws {
        do {
            try database?.updateTable(tableName: "constitute", filter: Expression<String>("configuration_name") == configuration_name, values: Expression<String>("configuration_name") <- newName)
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    // 删除设备组成
    open func deleteConstitute(configuration_name: String) throws {
        do {
            try database?.drop(tableName: "constitute", column: Expression<String>("configuration_name") == configuration_name)
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    // 获取设备组成信息
    open func getConstitute(device_name: String) -> [(configuration_name: String, component: [(component_type: String, model_id: String)])]? {
        let configs = database?.getRowBySelect(database?.select(tableName: "constitute", column: Expression<String>("configuration_name"))?.filter(Expression<String>("device_name") == device_name))
        if configs == nil {
            return nil
        }
        var result = [(configuration_name: String, component: [(component_type: String, model_id: String)])]()
        for config in configs! {
            let config_name = config.get(Expression<String>("configuration_name"))
            var con_array = [(component_type: String, model_id: String)]()
            let cons = database?.getRowBySelect(database?.selectAll(tableName: "constitute")?.filter(Expression<String>("configuration_name") == config_name && Expression<String>("device_name") == device_name))
            if cons == nil {
                return nil
            }
            for row in cons! {
                con_array.append((row.get(Expression<String>("component_type")), row.get(Expression<String>("component_id"))))
            }
            result.append((config_name, con_array))
        }
        return result
    }
    open func getConstituteForComponents(configuration_name: String) -> [String]? {
        let rows = database?.getRowBySelect(database?.select(tableName: "constitute", column: Expression<String>("component_id"))?.filter(Expression<String>("configuration_name") == configuration_name))
        if rows == nil {
            return nil
        }
        var result = [String]()
        for row in rows! {
            result.append(row.get(Expression<String>("component_id")))
        }
        return result
    }
    
    // MARK:- 厂家相关
    // 建立厂家表
    open func createTable_factory() throws {
        do {
            try database?.createTable(tableName: "factory", tableProperty: { (tb) in
                tb.column(Expression<String>("name"), primaryKey: true)
            })
        } catch {
            throw MainFunctionsError.createTableError
        }
        database?.createIndex(tableName: "factory", column: Expression<String>("name"))
    }
    // 添加厂家信息
    open func addFactory(name: String) throws {
        do {
            try database?.insertTable(tableName: "factory", values: Expression<String>("name") <- name)
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    // 删除厂家信息
    open func deleteFactory(name: String) throws {
        do {
            try database?.drop(tableName: "factory", column: Expression<String>("name") == name)
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    // 查询厂家信息
    open func getFactories() -> [String]? {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "factory"))
        if rows == nil {
            return nil
        }
        var result = [String]()
        for row in rows! {
            result.append(row.get(Expression<String>("name")))
        }
        return result
    }
    // 更改厂家信息
    open func alterFactory(name: String, newName: String) throws {
        do {
            try database?.updateTable(tableName: "factory", values: Expression<String>("name") <- newName)
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    
    // MARK:- 生产相关
    // 创建生产表
    open func createTable_product() throws {
        do {
            try database?.createTable(tableName: "product", tableProperty: { (tb) in
                tb.column(Expression<String>("factory_name"))
                tb.column(Expression<String>("component_id"))
                tb.foreignKey(Expression<String>("factory_name"), references: Table("factory"), Expression<String>("name"), update: .cascade, delete: .cascade)
                tb.foreignKey(Expression<String>("component_id"), references: Table("component"), Expression<String>("model_id"), update: .cascade, delete: .cascade)
                tb.primaryKey(Expression<String>("factory_name"), Expression<String>("component_id"))
            })
            // 为生产表的component_id建立索引
            database?.createIndex(tableName: "product", column: Expression<String>("component_id"))
        } catch {
            throw MainFunctionsError.createTableError
        }
    }
    // 添加生产信息
    open func addProduct(factory_name: String, component_id: String) throws {
        do {
            try database?.insertTable(tableName: "product", values: Expression<String>("factory_name") <- factory_name, Expression<String>("component_id") <- component_id)
        } catch {
            throw MainFunctionsError.insertError
        }
    }
    // 更改生产信息
    open func alterProduct(factory_name: String, newName: String, component_id: String, newId: String) throws {
        do {
            try database?.updateTable(tableName: "product", filter: Expression<String>("factory_name") == factory_name && Expression<String>("component_id") == component_id, values: Expression<String>("factory_name") <- factory_name, Expression<String>("component_id") <- component_id)
        } catch {
            throw MainFunctionsError.alterTableError
        }
    }
    // 删除生产信息
    open func deleteProduct(factory_name: String, component_id: String) throws {
        do {
            try database?.drop(tableName: "product", column: Expression<String>("factory_name") == factory_name && Expression<String>("component_id") == component_id)
        } catch {
            throw MainFunctionsError.deleteError
        }
    }
    // 获取生产信息
    open func getProduct(factory_name: String) -> [String]? {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "product")?.filter(Expression<String>("factory_name") == factory_name))
        if rows == nil {
            return nil
        }
        var result = [String]()
        for row in rows! {
            result.append(row.get(Expression<String>("component_id")))
        }
        return result
    }
    open func getProducts() -> [(factory_name: String, component_id: String)]? {
        let rows = database?.getRowBySelect(database?.selectAll(tableName: "product"))
        if rows == nil {
            return nil
        }
        var result = [(factory_name: String, component_id: String)]()
        for row in rows! {
            result.append((row.get(Expression<String>("factory_name")), row.get(Expression<String>("component_id"))))
        }
        return result
    }
}
// MARK:- 对外接口
class MainFunctions : MainFunctions_Basic {
    open func initDatabase() throws {
        try createTable_user()
        try createTable_device()
        try createTable_purches()
        try createTabel_component()
        try createTable_constitute()
        try createTable_factory()
        try createTable_product()
    }
    
    class func isExists(dbName: String) -> Bool {
        let path = DBM.dbFilePath
        if path == nil {
            return true
        }
        return FileManager.default.fileExists(atPath: path! + "/\(dbName).sqlite3")
    }
    
    class func copyFile(from: String, to: String) throws {
        try FileManager.default.copyItem(atPath: from, toPath: to)
    }
}
