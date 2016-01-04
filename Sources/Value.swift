//
//  Value.swift
//  MySQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import SQL

public struct Value: SQL.Value  {
    
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
}