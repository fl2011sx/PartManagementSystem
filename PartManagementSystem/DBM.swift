//
//  DBM.swift
//  PartManagementSystem
//
//  Created by 胡博豪 on 2017/6/11.
//  Copyright © 2017年 胡博豪. All rights reserved.
//

import SQLite

public class DBM {
    enum DBM_Error : Error {
        case initDbFilePathError
        case databaseConnectingError
        case tableCreateError
        case rowInsertError
        case rowUpdateError
        case dropRowError
        case tableDeleteError
        case sqlQueryError
    }
    
    public static var dbFilePath: String?
    public class func initDbFilePath() throws {
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/" + Bundle.main.bundleIdentifier! + "/dbFiles"
        Swift.print(path) // debug
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw DBM_Error.initDbFilePathError
        }
        dbFilePath = path
    }
    
    private var dbName: String?
    private var dbCon: Connection?
    
    init(_ dbName: String?, read_only: Bool = false) throws {
        self.dbName = dbName
        if DBM.dbFilePath == nil && dbName != nil {
            do {
                try DBM.initDbFilePath()
            } catch DBM_Error.initDbFilePathError {
                print("Path for saving database file initial failed!")
                throw DBM_Error.initDbFilePathError
            }
        }
        do {
            if (dbName != nil) {
                try dbCon = Connection("\(DBM.dbFilePath!)/\(dbName!).sqlite3", readonly: read_only)
            } else {
                try dbCon = Connection(.temporary, readonly:read_only)
            }
            try customSQLRun("PRAGMA foreign_keys = ON")
        } catch {
            print("Database connecting failed!")
            throw DBM_Error.databaseConnectingError
        }
    }
    
    public func createTable(tableName: String, tableProperty: (TableBuilder) -> ()) throws {
        do {
            let tb = Table(tableName)
            try dbCon?.run(tb.create(ifNotExists: true, block:tableProperty))
        } catch {
            throw DBM_Error.tableCreateError
        } 
    }
    
    public func createView(tableName: String, select: [Expressible], filter: Expression<Bool>?, viewName: String) {
        let tb = Table(tableName)
        let view = View(viewName)
        if filter != nil {
            _ = view.create(tb.select(select).filter(filter!))
        } else {
            _ = view.create(tb.select(select))
        }
    }
    
    public func createIndex(tableName: String, column: Expressible) {
        let tb = Table(tableName)
        _ =  tb.createIndex(column)
    }
    
    public func insertTable(tableName: String, values: Setter...) throws {
        do {
            let tb = Table(tableName)
            try dbCon?.run(tb.insert(values))
        } catch {
            throw DBM_Error.rowInsertError
        }
    }
    
    public func updateTable(tableName: String, filter: Expression<Bool>? = nil, values: Setter...) throws {
        do {
            let tb = filter == nil ? Table(tableName) : Table(tableName).filter(filter!)
            try dbCon?.run(tb.update(values))
        } catch {
            throw DBM_Error.rowUpdateError
        }
    }
    
    public func select(tableName: String, column: Expressible...) -> Table? {
        let tb = Table(tableName)
        return tb.select(distinct: column)
    }
    
    public func selectAll(tableName: String) -> Table? {
        let tb = Table(tableName)
        return tb.select(*)
    }
    
    public func getRowBySelect(_ select: Table?) ->  AnySequence<Row>? {
        if select == nil {
            return nil
        }
        do {
            return try dbCon?.prepare(select!)
        } catch {
            return nil
        }
    }
    
    public func drop(tableName: String, column: Expression<Bool>) throws {
        do {
            let tb = Table(tableName)
            try dbCon?.run(tb.filter(column).delete())
        } catch {
            throw DBM_Error.dropRowError
        }
    }
    
    public func deleteTable(tableName: String) throws {
        do {
            let tb = Table(tableName)
            try dbCon?.run(tb.delete())
        } catch {
            throw DBM_Error.tableDeleteError
        }
    }
    
    public func getColumnName(tableName: String) throws -> [String]? {
        do {
            return try dbCon?.prepare("SELECT * FROM \(tableName);").columnNames
        } catch {
            throw DBM_Error.sqlQueryError
        }
    }
    
    public func customSQLRun(_ SQL: String) throws {
        try dbCon?.execute(SQL)
    }
    
    public func customSQLQuery(_ SQL: String) throws -> Statement? {
        return try dbCon?.prepare(SQL)
    }
}
