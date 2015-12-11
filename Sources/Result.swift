//
//  Result.swift
//  MySQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import CMySQL
import SQL

public class Result: SQL.Result {
    
    public let resultPointer: UnsafeMutablePointer<MYSQL_RES>
    
    public init(_ resultPointer: UnsafeMutablePointer<MYSQL_RES>) {
        self.resultPointer = resultPointer
    }
    
    deinit {
        clear()
    }
    
    public func clear() {
        mysql_free_result(resultPointer)
    }
    
    
    public subscript(position: Int) -> Row {
        
        var result: [String: Value] = [:]
        
        mysql_data_seek(resultPointer, UInt64(position))
        
        let row = mysql_fetch_row(resultPointer)
        
        let lengths = mysql_fetch_lengths(resultPointer)
        
        for (fieldIndex, field) in fields.enumerate() {

            let val = row[fieldIndex]
            let length = Int(lengths[fieldIndex])
            
            var buffer = [UInt8](count: length, repeatedValue: 0)
            
            memcpy(&buffer, val, length)
            
            result[field.name] = Value(data: buffer)
        }
        
        return Row(valuesByName: result)
    }
    
    public var count: Int {
        return Int(mysql_num_rows(resultPointer))
    }
    
    public lazy var fields: [Field] = {
        var result: [Field] = []
        
        for i in 0..<mysql_num_fields(self.resultPointer) {
            
            result.append(
                Field(mysql_fetch_field_direct(self.resultPointer, i))
            )
        }
        
        return result
        
    }()
}
