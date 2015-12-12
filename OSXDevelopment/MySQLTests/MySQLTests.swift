//
//  MySQLTests.swift
//  MySQLTests
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import XCTest
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
        let connection = Connection("mysql://localhost/test")
        
        do {
            try connection.open()
            
            let result = try connection.execute("SELECT * FROM user")
            
            print(result.fields)
            
            for row in result {
                print(row["id"]?.integer)
            }
        }
        catch {
            print(error)
            print("!")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
