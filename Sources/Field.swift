//
//  Field.swift
//  MySQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import SQL
import CMySQL

public struct Field: SQL.Field {
    
    public var name: String
    
    public var originalName: String
    
    public var table: String
    
    public var originalTable: String
    
    public var database: String
    
    public var catalog: String
    
    public var length: UInt
    
    public var maxLength: UInt
    
    public init(_ pointer: UnsafePointer<MYSQL_FIELD>) {
        name = String.fromCString(pointer.memory.name)!
        originalName = String.fromCString(pointer.memory.org_name)!
        table = String.fromCString(pointer.memory.table)!
        originalTable = String.fromCString(pointer.memory.org_table)!
        database = String.fromCString(pointer.memory.db)!
        catalog = String.fromCString(pointer.memory.catalog)!
        length = pointer.memory.length
        maxLength = pointer.memory.max_length
    }
}
