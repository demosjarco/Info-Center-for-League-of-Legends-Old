//
//  PlistManager.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/23/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class PlistManager: NSObject {
    func loadRecentSummoners() -> NSArray {
        if let region = UserDefaults.standard.string(forKey: "league_region") {
            if let recentSummoners = NSArray(contentsOfFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(recentSummonersFileName(region))) {
                return recentSummoners
            } else {
                return NSArray()
            }
        } else {
            return NSArray()
        }
    }
    
    func addToRecentSummoners(_ newSummoner: SummonerDto) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        if !recentSummoners.contains(newSummoner.summonerId) {
            recentSummoners.insert(newSummoner.summonerId, at: 0)
            
            if !FileManager.default.fileExists(atPath: self.getDocumentDirectory().appending(self.baseDatabaseDirectory)) {
                do {
                    try FileManager.default.createDirectory(atPath: self.getDocumentDirectory().appending(self.baseDatabaseDirectory), withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
            
            recentSummoners.write(toFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(self.recentSummonersFileName(Endpoints().getRegion())), atomically: true)
        }
    }
    
    func moveItemInRecentSummoners(oldIndex: Int, newIndex: Int) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        let item = recentSummoners.object(at: oldIndex)
        recentSummoners.removeObject(at: oldIndex)
        recentSummoners.insert(item, at: newIndex)
        
        recentSummoners.write(toFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(self.recentSummonersFileName(Endpoints().getRegion())), atomically: true)
    }
    
    func removeItemInRecentSummoners(oldIndex: Int) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        recentSummoners.removeObject(at: oldIndex)
        
        recentSummoners.write(toFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(self.recentSummonersFileName(Endpoints().getRegion())), atomically: true)
    }
    
    // Local
    let baseDatabaseDirectory: String = "/databases"
    
    func recentSummonersFileName(_ regionCode: String) -> String {
        return "/" + regionCode + "_recentSummoners.plist"
    }
    let rankedSummonerHistoryDirectoy: String = "/rankedSummonerHistory"
    
    let profileViewTileOrderName: String = "/profileViewTileOrder.plist"
    
    func getDocumentDirectory() -> String {
        // print("DATABASE DIRECTORY: " + NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    func loadProfileViewTileOrder() -> NSArray {
        if let tileOrder = NSArray(contentsOfFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(profileViewTileOrderName)) {
            return tileOrder
        } else {
            let tempTileOrder = NSMutableArray()
            tempTileOrder.insert(NSDictionary(object: "champMastery", forKey: "tileType" as NSCopying), at: 0)
            tempTileOrder.insert(NSDictionary(object: "recentGames", forKey: "tileType" as NSCopying), at: 1)
            tempTileOrder.insert(NSDictionary(object: "masteries", forKey: "tileType" as NSCopying), at: 2)
            tempTileOrder.insert(NSDictionary(object: "runes", forKey: "tileType" as NSCopying), at: 3)
            
            return NSArray(array: tempTileOrder)
        }
    }
    func writeTileOrder(_ tileOrder: NSArray) {
        if !FileManager.default.fileExists(atPath: getDocumentDirectory().appending(baseDatabaseDirectory)) {
            do {
                try FileManager.default.createDirectory(atPath: getDocumentDirectory().appending(baseDatabaseDirectory), withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        tileOrder.write(toFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(profileViewTileOrderName), atomically: true)
    }
}
