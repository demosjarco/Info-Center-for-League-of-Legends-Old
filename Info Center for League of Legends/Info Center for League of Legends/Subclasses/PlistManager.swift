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
        if let recentSummoners = NSArray(contentsOfFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(recentSummonersFileName(regionCode: Endpoints().getRegion()))) {
            return recentSummoners
        } else {
            return NSArray()
        }
    }
    
    func addToRecentSummoners(newSummoner: SummonerDto) {
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
            
            recentSummoners.write(toFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(self.recentSummonersFileName(regionCode: Endpoints().getRegion())), atomically: true)
        }
    }
    
    func moveItemInRecentSummoners(oldIndex: Int, newIndex: Int) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        let item = recentSummoners.object(at: oldIndex)
        recentSummoners.removeObject(at: oldIndex)
        recentSummoners.insert(item, at: newIndex)
        
        recentSummoners.write(toFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(self.recentSummonersFileName(regionCode: Endpoints().getRegion())), atomically: true)
    }
    
    func removeItemInRecentSummoners(oldIndex: Int) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        recentSummoners.removeObject(at: oldIndex)
        
        recentSummoners.write(toFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(self.recentSummonersFileName(regionCode: Endpoints().getRegion())), atomically: true)
    }
    
    // Local
    let baseDatabaseDirectory: String = "/databases"
    
    func recentSummonersFileName(regionCode: String) -> String {
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
            tempTileOrder.insert(NSDictionary(object: "champMastery", forKey: "tileType"), at: 0)
            tempTileOrder.insert(NSDictionary(object: "recentGames", forKey: "tileType"), at: 1)
            tempTileOrder.insert(NSDictionary(object: "masteries", forKey: "tileType"), at: 2)
            tempTileOrder.insert(NSDictionary(object: "runes", forKey: "tileType"), at: 3)
            tempTileOrder.insert(NSDictionary(object: "teams", forKey: "tileType"), at: 4)
            
            return NSArray(array: tempTileOrder)
        }
    }
    func writeTileOrder(tileOrder: NSArray) {
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
