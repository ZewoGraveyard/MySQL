//
//  Connection.swift
//  MySQL
//
//  Created by David Ask on 10/12/15.
//  Copyright © 2015 Formbound. All rights reserved.
//

import CMySQL
import SQL

public class Connection: SQL.Connection {
    
    public enum Error: ErrorType {
        case ErrorCode(UInt, String)
        case BadResult
    }
    
    public enum Status {
        case OK
    }
    
    public class Info: SQL.ConnectionInfo, ConnectionStringConvertible {
        
        public struct Flags : OptionSetType {
            public let rawValue: UInt
            public init(rawValue: UInt) { self.rawValue = rawValue }
            
            static let None = 0
            
            static let CanHandleExpiredPasswords = CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS
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
        
        public init(host: String, database: String, port: UInt = 3306, user: String? = nil, password: String? = nil, flags: Flags = Flags(rawValue: 0)) {
            self.flags = flags
            super.init(host: host, database: database, port: port, user: user, password: password)
        }

        required convenience public init(unicodeScalarLiteral value: String) {
            fatalError("init(unicodeScalarLiteral:) has not been implemented")
        }

        required convenience public init(stringLiteral: String) {
            fatalError("init(stringLiteral:) has not been implemented")
        }

        required convenience public init(connectionString: String) {
            fatalError("init(connectionString:) has not been implemented")
        }

        required convenience public init(extendedGraphemeClusterLiteral value: String) {
            fatalError("init(extendedGraphemeClusterLiteral:) has not been implemented")
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
    
    public func execute(string: String) throws -> Result {
        guard mysql_real_query(connection, string, UInt(string.utf8.count)) == 0 else {
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