//
//  PlistManager.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/23/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class PlistManager: NSObject {
    let baseDatabaseDirectory: String = "/databases"
    
    let recentSummonersFileName: String = "/recentSummoners.plist"
    let rankedSummonerHistoryDirectoy: String = "/rankedSummonerHistory"
    
    func getDocumentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    func loadRecentSummoners() -> NSArray {
        if let recentSummoners = NSArray(contentsOfFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(recentSummonersFileName)) {
            return recentSummoners
        } else {
            return NSArray()
        }
    }
    func addToRecentSummoners(newSummoner: SummonerDto) -> NSArray {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        recentSummoners.insert(newSummoner.summonerId, at: 0)
        
        recentSummoners.write(toFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(recentSummonersFileName), atomically: true)
        return NSArray(array: recentSummoners)
    }
    func moveItemInRecentSummoners(oldIndex: Int, newIndex: Int) -> NSArray {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        let item = recentSummoners.object(at: oldIndex)
        recentSummoners.removeObject(at: oldIndex)
        recentSummoners.insert(item, at: newIndex)
        
        recentSummoners.write(toFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(recentSummonersFileName), atomically: true)
        return NSArray(array: recentSummoners)
    }
}
