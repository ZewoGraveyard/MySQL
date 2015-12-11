//
//  Row.swift
//  MySQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import SQL

public struct Row: SQL.Row {
    public typealias ValueType = Value
    
    public init(valuesByName: [String: Value]) {
        self.valuesByName = valuesByName
    }
    
    public let valuesByName: [String: Value]
}