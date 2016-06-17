//
//  DBManager.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/17/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class DBManager: NSObject {
    var dbFilePath: String = ""
    
    var arrResults: NSMutableArray = []
    var arrColumnNames: NSMutableArray = []
    var affectedRows: Int = 0
    var lastInsertedRowID: CLongLong = 0
    
    func initializeDb(databaseName:String) -> Bool {
        let documentFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let dbfile = "/" + databaseName + ".sqlite3";
        dbFilePath = documentFolderPath.appending(dbfile)
        
        if (!FileManager.default().fileExists(atPath: dbFilePath)) {
            let backupDbPath = Bundle.main().pathForResource(databaseName, ofType:"sqlite3")
            
            if (backupDbPath == nil) {
                return false
            } else {
                do {
                    try FileManager.default().copyItem(atPath: backupDbPath!, toPath:dbFilePath)
                } catch let error as NSError {
                    print("copy failed: \(error.localizedDescription)")
                    return false
                }
            }
        } else {
            /*do {
             try FileManager.default().removeItem(atPath: dbFilePath)
             } catch let error as NSError {
             print("delete failed: \(error.localizedDescription)")
             }*/
        }
        return true
    }
    
    func runQuery(query:String, queryExecutable:Bool) {
        if initializeDb(databaseName: "recentSummoners") {
            var sqlite3Database: OpaquePointer?
            
            // Initialize the results array.
            arrResults.removeAllObjects()
            arrResults = NSMutableArray()
            
            // Initialize the column names array.
            arrColumnNames.removeAllObjects()
            arrColumnNames = NSMutableArray()
            
            if sqlite3_open(dbFilePath, &sqlite3Database) != SQLITE_OK {
                var compiledStatement: OpaquePointer?
                
                if sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, nil) == SQLITE_OK {
                    if queryExecutable {
                        // In this case data must be loaded from the database.
                    } else {
                        // This is the case of an executable query (insert, update, ...)
                    }
                }
            }
        }
    }
}
