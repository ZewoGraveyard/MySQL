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
        name = String(validatingUTF8: pointer.pointee.name)!
        originalName = String(validatingUTF8: pointer.pointee.org_name)!
        table = String(validatingUTF8: pointer.pointee.table)!
        originalTable = String(validatingUTF8: pointer.pointee.org_table)!
        database = String(validatingUTF8: pointer.pointee.db)!
        catalog = String(validatingUTF8: pointer.pointee.catalog)!
        length = pointer.pointee.length
        maxLength = pointer.pointee.max_length
    }
}
