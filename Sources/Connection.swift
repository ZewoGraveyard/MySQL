//
//  Connection.swift
//  MySQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import CMySQL
import SQL
import Foundation

public class Connection: SQL.Connection {
    
    public enum Error: ErrorType {
        case ErrorCode(UInt, String)
        case BadResult
        case ParameterError(String)
    }
    
    public enum Status {
        case OK
    }
    
    public class Info: SQL.ConnectionInfo, ConnectionStringConvertible {
        
        public struct Flags : OptionSetType {
            public let rawValue: UInt
            public init(rawValue: UInt) { self.rawValue = rawValue }
            
            static let None = 0
        
            // TODO: Version specific options
            static let Compress = CLIENT_COMPRESS
            static let FoundRows = CLIENT_FOUND_ROWS
            static let IgnoreSigPipe = CLIENT_IGNORE_SIGPIPE
            static let IgnoreSpace = CLIENT_IGNORE_SPACE
            static let Interactive = CLIENT_INTERACTIVE
            static let LocalFiles = CLIENT_LOCAL_FILES
            static let MultiResults = CLIENT_MULTI_RESULTS
            static let MultiStatements = CLIENT_MULTI_STATEMENTS
            static let NoSchema = CLIENT_NO_SCHEMA
            static let ODBC = CLIENT_ODBC
            static let SSL = CLIENT_SSL
            static let RememberOptions = CLIENT_REMEMBER_OPTIONS
        }
        
        let flags: Flags
        
        public var connectionString: String {
            var userInfo = ""
            if let user = user {
                userInfo = user
                
                if let password = password {
                    userInfo += ":\(password)@"
                }
                else {
                    userInfo += "@"
                }
            }
            
            return "mysql://\(userInfo)\(host):\(port)/\(database)"
        }
        
        public init(host: String, database: String, port: UInt = UInt(MYSQL_PORT), user: String? = nil, password: String? = nil, flags: Flags = Flags(rawValue: 0)) {
            self.flags = flags
            super.init(host: host, database: database, port: port, user: user, password: password)
        }
        
        public convenience required init(connectionString: String) {
            guard let URL = NSURL(string: connectionString) else {
                fatalError("Invalid connection string")
            }
            
            guard let host = URL.host else {
                fatalError("Missing host in connection string")
            }
            
            guard let database = URL.pathComponents?.last else {
                fatalError("Missing database in connection string")
            }
            
            let port = URL.port?.unsignedIntegerValue ?? UInt(MYSQL_PORT)
            
            self.init(
                host: host,
                database: database,
                port: port,
                user: URL.user ?? "root",
                password: URL.password
            )
        }
        
        public required convenience init(stringLiteral: String) {
            self.init(connectionString: stringLiteral)
        }
        
        public required convenience init(extendedGraphemeClusterLiteral value: String) {
            self.init(connectionString: value)
        }
        
        public required convenience init(unicodeScalarLiteral value: String) {
            self.init(connectionString: value)
        }
        
        public var description: String {
            return connectionString
        }
    }
    
    private let connection: UnsafeMutablePointer<MYSQL>
    
    private(set) public var connectionInfo: Info
    
    public required init(_ connectionInfo: Info) {
        self.connectionInfo = connectionInfo
        connection = mysql_init(nil)
    }
    
    deinit {
        close()
    }
    
    public var status: Status {
        return .OK
    }
    
    public func open() throws {
        guard mysql_real_connect(
            connection,
            connectionInfo.host,
            connectionInfo.user ?? "",
            connectionInfo.password ?? "",
            connectionInfo.database,
            UInt32(connectionInfo.port),
            nil,
            connectionInfo.flags.rawValue
            ) != nil else {
                throw statusError
        }
    }
    
    public func close() {
        mysql_close(connection)
    }
    
    public func execute(string: String, parameters: [String: CustomStringConvertible]) throws -> Result {
        
        var statement = string
        
        for (key, value) in parameters {
            
            try value.description.withCString {
                cstr in
                
                let escapedPointer = UnsafeMutablePointer<Int8>.alloc(value.description.characters.count)
                
                defer {
                    escapedPointer.destroy()
                    escapedPointer.dealloc(value.description.characters.count)
                }
                
                let len = mysql_real_escape_string(connection, escapedPointer, cstr, strlen(cstr))
                escapedPointer[Int(len)] = 0
                
                guard let escapedString = String.fromCString(escapedPointer) else {
                    throw Error.ParameterError(key)
                }
                
                statement = statement.stringByReplacingOccurrencesOfString(
                    ":\(key)",
                    withString: "\'\(escapedString)\'"
                )
            }
        }
        
        guard mysql_real_query(connection, statement, UInt(statement.utf8.count)) == 0 else {
            throw statusError
        }
        
        let result = mysql_store_result(connection)
        
        guard result != nil else {
            guard mysql_field_count(connection) == 0 else {
                throw Error.BadResult
            }
            
            return Result(nil)
        }
        
        return Result(result)
    }
    
    public func createSavePointNamed(name: String) throws {
        try execute("SAVEPOINT \(name)")
    }
    
    public func releaseSavePointNamed(name: String) throws {
        try execute("RELEASE SAVEPOINT \(name)")
    }
    
    public func rollbackToSavePointNamed(name: String) throws {
        try execute("ROLLBACK TO SAVEPOINT \(name)")
    }
    
    private var statusError: Error {
        return Error.ErrorCode(
            UInt(mysql_errno(connection)),
            String.fromCString(mysql_error(connection)) ?? "None"
        )
    }
}