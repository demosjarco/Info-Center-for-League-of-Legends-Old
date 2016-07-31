//
//  PlistManager.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/23/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import CloudKit

class PlistManager: NSObject {
    // iCloud
    func checkIfUserEnabledIcloud(icloudReady: () -> Void, icloudUnavailable: () -> Void) {
        if (UserDefaults.standard.object(forKey: "league_useIcloud") == nil) {
            UserDefaults.standard.set(true, forKey: "league_useIcloud")
        }
        
        if UserDefaults.standard.bool(forKey: "league_useIcloud") {
            CKContainer.default().accountStatus { (accountStatus, error) in
                if accountStatus == CKAccountStatus.available {
                    icloudReady()
                } else {
                    icloudUnavailable()
                }
            }
        } else {
            icloudUnavailable()
        }
    }
    
    func loadRecentSummoners(completion: (recentSummoners: NSArray) -> Void) {
        checkIfUserEnabledIcloud(icloudReady: {
            // iCloud good - keep in sync
            CKContainer.default().privateCloudDatabase.fetch(withRecordID: CKRecordID(recordName: "savedSummoners"), completionHandler: { (record, error) in
                if (error != nil) {
                    // Not saved in iCloud
                    
                    // Check if local and upload
                    let summonerRecord = CKRecord(recordType: "recentSummoners", recordID: CKRecordID(recordName: "savedSummoners"))
                    // Add summoners
                    self.loadLocalRecentSummoners(regionCode: "na", completion: { (recentSummoners) in
                        summonerRecord["na"] = recentSummoners as! [Int]
                        
                        self.loadLocalRecentSummoners(regionCode: "euw", completion: { (recentSummoners) in
                            summonerRecord["euw"] = recentSummoners as! [Int]
                            
                            self.loadLocalRecentSummoners(regionCode: "eune", completion: { (recentSummoners) in
                                summonerRecord["eune"] = recentSummoners as! [Int]
                                
                                self.loadLocalRecentSummoners(regionCode: "lan", completion: { (recentSummoners) in
                                    summonerRecord["lan"] = recentSummoners as! [Int]
                                    
                                    self.loadLocalRecentSummoners(regionCode: "las", completion: { (recentSummoners) in
                                        summonerRecord["las"] = recentSummoners as! [Int]
                                        
                                        self.loadLocalRecentSummoners(regionCode: "br", completion: { (recentSummoners) in
                                            summonerRecord["br"] = recentSummoners as! [Int]
                                            
                                            self.loadLocalRecentSummoners(regionCode: "jp", completion: { (recentSummoners) in
                                                summonerRecord["jp"] = recentSummoners as! [Int]
                                                
                                                self.loadLocalRecentSummoners(regionCode: "ru", completion: { (recentSummoners) in
                                                    summonerRecord["ru"] = recentSummoners as! [Int]
                                                    
                                                    self.loadLocalRecentSummoners(regionCode: "tr", completion: { (recentSummoners) in
                                                        summonerRecord["tr"] = recentSummoners as! [Int]
                                                        
                                                        self.loadLocalRecentSummoners(regionCode: "oce", completion: { (recentSummoners) in
                                                            summonerRecord["oce"] = recentSummoners as! [Int]
                                                            
                                                            CKContainer.default().privateCloudDatabase.save(summonerRecord, completionHandler: { (savedRecord, saveError) in
                                                                if (saveError != nil) {
                                                                    // Didn't save
                                                                    print(String(saveError))
                                                                }
                                                            })
                                                            /*self.loadLocalRecentSummoners(regionCode: "kr", completion: { (recentSummoners) in
                                                                summonerRecord["kr"] = recentSummoners as! [Int]
                                                            })*/
                                                        })
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                    
                    // Return back to view
                    Endpoints().getRegion { (regionCode) in
                        self.loadLocalRecentSummoners(regionCode: regionCode, completion: { (recentSummoners) in
                            completion(recentSummoners: recentSummoners)
                        })
                    }
                } else {
                    // Saved in iCloud
                    
                    // Check if any differences and merge non duplicates
                    let na = record!["na"] as! [Int]
                    let euw = record!["euw"] as! [Int]
                    let eune = record!["eune"] as! [Int]
                    let lan = record!["lan"] as! [Int]
                    let las = record!["las"] as! [Int]
                    let br = record!["br"] as! [Int]
                    let jp = record!["jp"] as! [Int]
                    let ru = record!["ru"] as! [Int]
                    let tr = record!["tr"] as! [Int]
                    let oce = record!["oce"] as! [Int]
                    // let kr = record!["kr"] as! [Int]
                    
                    self.loadLocalRecentSummoners(regionCode: "na", completion: { (recentSummoners) in
                        record!["na"] = self.mergeSummonerArrays(cloudArray: na, localArray: recentSummoners as! [Int])
                        
                        self.loadLocalRecentSummoners(regionCode: "euw", completion: { (recentSummoners) in
                            record!["euw"] = self.mergeSummonerArrays(cloudArray: euw, localArray: recentSummoners as! [Int])
                            
                            self.loadLocalRecentSummoners(regionCode: "eune", completion: { (recentSummoners) in
                                record!["eune"] = self.mergeSummonerArrays(cloudArray: eune, localArray: recentSummoners as! [Int])
                                
                                self.loadLocalRecentSummoners(regionCode: "lan", completion: { (recentSummoners) in
                                    record!["lan"] = self.mergeSummonerArrays(cloudArray: lan, localArray: recentSummoners as! [Int])
                                    
                                    self.loadLocalRecentSummoners(regionCode: "las", completion: { (recentSummoners) in
                                        record!["las"] = self.mergeSummonerArrays(cloudArray: las, localArray: recentSummoners as! [Int])
                                        
                                        self.loadLocalRecentSummoners(regionCode: "br", completion: { (recentSummoners) in
                                            record!["br"] = self.mergeSummonerArrays(cloudArray: br, localArray: recentSummoners as! [Int])
                                            
                                            self.loadLocalRecentSummoners(regionCode: "jp", completion: { (recentSummoners) in
                                                record!["jp"] = self.mergeSummonerArrays(cloudArray: jp, localArray: recentSummoners as! [Int])
                                                
                                                self.loadLocalRecentSummoners(regionCode: "ru", completion: { (recentSummoners) in
                                                    record!["ru"] = self.mergeSummonerArrays(cloudArray: ru, localArray: recentSummoners as! [Int])
                                                    
                                                    self.loadLocalRecentSummoners(regionCode: "tr", completion: { (recentSummoners) in
                                                        record!["tr"] = self.mergeSummonerArrays(cloudArray: tr, localArray: recentSummoners as! [Int])
                                                        
                                                        self.loadLocalRecentSummoners(regionCode: "oce", completion: { (recentSummoners) in
                                                            record!["oce"] = self.mergeSummonerArrays(cloudArray: oce, localArray: recentSummoners as! [Int])
                                                            
                                                            CKContainer.default().privateCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                                                if (saveError != nil) {
                                                                    // Didn't save
                                                                    print(String(saveError))
                                                                }
                                                            })
                                                            /*self.loadLocalRecentSummoners(regionCode: "kr", completion: { (recentSummoners) in
                                                                record!["kr"] = self.mergeSummonerArrays(cloudArray: kr, localArray: recentSummoners as! [Int])
                                                            })*/
                                                        })
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                }
            })
        }) {
            // iCloud unavailable - use local only
            Endpoints().getRegion { (regionCode) in
                self.loadLocalRecentSummoners(regionCode: regionCode, completion: { (recentSummoners) in
                    completion(recentSummoners: recentSummoners)
                })
            }
        }
    }
    
    func mergeSummonerArrays(cloudArray: [Int], localArray: [Int]) -> [Int] {
        var newArray = [Int]()
        
        for summoner in cloudArray {
            if !newArray.contains(summoner) {
                newArray.append(summoner)
            }
        }
        for summoner in localArray {
            if !newArray.contains(summoner) {
                newArray.append(summoner)
            }
        }
        
        return newArray
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
    
    func loadLocalRecentSummoners(regionCode: String, completion: (recentSummoners: NSArray) -> Void) {
        if let recentSummoners = NSArray(contentsOfFile: self.getDocumentDirectory().appending(self.baseDatabaseDirectory).appending(recentSummonersFileName(regionCode: regionCode))) {
            completion(recentSummoners: recentSummoners)
        } else {
            completion(recentSummoners: NSArray())
        }
    }
    
    /*
    func addToRecentSummoners(newSummoner: SummonerDto) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        if !recentSummoners.contains(newSummoner.summonerId) {
            recentSummoners.insert(newSummoner.summonerId, at: 0)
            
            if !FileManager.default.fileExists(atPath: getDocumentDirectory().appending(baseDatabaseDirectory)) {
                do {
                    try FileManager.default.createDirectory(atPath: getDocumentDirectory().appending(baseDatabaseDirectory), withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    print(error.localizedDescription);
                }
            }
            recentSummoners.write(toFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(recentSummonersFileName), atomically: true)
        }
    }
    func moveItemInRecentSummoners(oldIndex: Int, newIndex: Int) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        let item = recentSummoners.object(at: oldIndex)
        recentSummoners.removeObject(at: oldIndex)
        recentSummoners.insert(item, at: newIndex)
        
        recentSummoners.write(toFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(recentSummonersFileName), atomically: true)
    }
    func removeItemInRecentSummoners(oldIndex: Int) {
        let recentSummoners = NSMutableArray(array: loadRecentSummoners())
        
        recentSummoners.removeObject(at: oldIndex)
        
        recentSummoners.write(toFile: getDocumentDirectory().appending(baseDatabaseDirectory).appending(recentSummonersFileName), atomically: true)
    }*/
    
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
