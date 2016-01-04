//
//  MySQLTests.swift
//  MySQLTests
//
//  Created by David Ask on 03/01/16.
//  Copyright © 2016 Zewo. All rights reserved.
//

import XCTest
import CMySQL
import MySQL
import SQL


class MySQLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let connection = Connection("mysql://root@localhost/test")
        
        do {
            try connection.open()
            
            let result = try connection.execute("select * from user where id = $2", parameters: 1)
            
            for row in result {
                print(row)
            }
        }
        catch {
            print(error)
            print("Error")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
