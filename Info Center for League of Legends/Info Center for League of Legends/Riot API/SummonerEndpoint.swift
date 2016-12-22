//
//  SummonerEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/23/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class SummonerEndpoint: NSObject {
    func getSummonersForSummonerNames(_ summonerNames: [String], completion: @escaping (_ summonerMap: [String: SummonerDto]) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        // Standardize names
        var standardizedSummonerNames = [String]()
        for summonerName:String in summonerNames {
            standardizedSummonerNames.append(summonerName.replacingOccurrences(of: " ", with: "").lowercased())
        }
        
        Endpoints().summoner_byName(standardizedSummonerNames.joined(separator: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                var newDict = [String: SummonerDto]()
                let dict = responseObject as! NSDictionary
                let dictValues = dict.allValues as! [[String: AnyObject]]
                for i in 0 ..< dictValues.count {
                    var oldSummoner = dictValues[i]
                    
                    let newSummoner = SummonerDto()
                    newSummoner.summonerId = oldSummoner["id"] as! CLong
                    newSummoner.name = oldSummoner["name"] as! String
                    newSummoner.profileIconId = oldSummoner["profileIconId"] as! Int
                    newSummoner.revisionDate = oldSummoner["revisionDate"] as! CLong
                    newSummoner.summonerLevel = oldSummoner["summonerLevel"] as! CLong
                    
                    newDict[dict.allKeys[i] as! String] = newSummoner
                }
                completion(newDict)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                if response.statusCode == 404 {
                    notFound()
                } else {
                    errorBlock()
                    FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                }
            })
        }
    }
    
    func getSummonersForIds(_ summonerIds: [CLong], completion: @escaping (_ summonerMap: [String: SummonerDto]) -> Void, errorBlock: @escaping () -> Void) {
        var stringSummonerIds = [String]()
        for summonerId in summonerIds {
            stringSummonerIds.append(String(summonerId))
        }
        
        Endpoints().summoner_byId(stringSummonerIds.joined(separator: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                var newDict = [String: SummonerDto]()
                let dict = responseObject as! NSDictionary
                let dictValues = dict.allValues as! [[String: AnyObject]]
                for i in 0 ..< dictValues.count {
                    let oldSummoner = dictValues[i]
                    
                    let newSummoner = SummonerDto()
                    newSummoner.summonerId = oldSummoner["id"] as! CLong
                    newSummoner.name = oldSummoner["name"] as! String
                    newSummoner.profileIconId = oldSummoner["profileIconId"] as! Int
                    newSummoner.revisionDate = oldSummoner["revisionDate"] as! CLong
                    newSummoner.summonerLevel = oldSummoner["summonerLevel"] as! CLong
                    
                    newDict[dict.allKeys[i] as! String] = newSummoner
                }
                completion(newDict)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getMasteriesForSummonerIds(_ summonerIds: [CLong], completion: @escaping (_ summonerMap: [String: MasteryPagesDto]) -> Void, errorBlock: @escaping () -> Void) {
        var stringSummonerIds = [String]()
        for summonerId in summonerIds {
            stringSummonerIds.append(String(summonerId))
        }
        
        Endpoints().summoner_masteriesById(stringSummonerIds.joined(separator: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                var newResponse = [String: MasteryPagesDto]()
                let json = responseObject as! NSDictionary
                let jsonValues = json.allValues as! [[String: AnyObject]]
                for i in 0 ..< jsonValues.count {
                    let oldMasteryPages = jsonValues[i]
                    
                    let newMasteryPages = MasteryPagesDto()
                    let oldPages = oldMasteryPages["pages"] as! [[String: AnyObject]]
                    
                    for oldPage in oldPages {
                        let newPage = MasteryPageDto()
                        
                        newPage.current = oldPage["current"] as! Bool
                        newPage.masteryPageId = oldPage["id"] as! CLong
                        if (oldPage["masteries"] != nil) {
                            let oldMasteries = oldPage["masteries"] as! [[String: AnyObject]]
                            for oldMastery in oldMasteries {
                                let newMastery = MasteryDto()
                                
                                newMastery.masteryId = oldMastery["id"] as! Int
                                newMastery.rank = oldMastery["rank"] as! Int
                                
                                newPage.masteries.append(newMastery)
                            }
                        }
                        newPage.name = oldPage["name"] as! String
                        
                        newMasteryPages.pages.append(newPage)
                    }
                    newMasteryPages.summonerId = oldMasteryPages["summonerId"] as! CLong
                    
                    newResponse[json.allKeys[i] as! String] = newMasteryPages
                }
                completion(newResponse)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getRunesForSummonerIds(_ summonerIds: [CLong], completion: @escaping (_ summonerMap: [String: RunePagesDto]) -> Void, errorBlock: @escaping () -> Void) {
        var stringSummonerIds = [String]()
        for summonerId in summonerIds {
            stringSummonerIds.append(String(summonerId))
        }
        
        Endpoints().summoner_runesById(stringSummonerIds.joined(separator: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                var newResponse = [String: RunePagesDto]()
                let json = responseObject as! NSDictionary
                let jsonValues = json.allValues as! [[String: AnyObject]]
                for i in 0 ..< jsonValues.count {
                    let oldRunePages = jsonValues[i]
                    
                    let newRunePages = RunePagesDto()
                    let oldPages = oldRunePages["pages"] as! [[String: AnyObject]]
                    
                    for oldPage in oldPages {
                        let newPage = RunePageDto()
                        
                        newPage.current = oldPage["current"] as! Bool
                        newPage.runePageId = oldPage["id"] as! CLong
                        if (oldPage["slots"] != nil) {
                            let oldSlots = oldPage["slots"] as! [[String: AnyObject]]
                            for oldSlot in oldSlots {
                                let newSlot = RuneSlotDto()
                                
                                newSlot.runeId = oldSlot["runeId"] as! Int
                                newSlot.runeSlotId = oldSlot["runeSlotId"] as! Int
                                
                                newPage.slots.append(newSlot)
                            }
                        }
                        newPage.name = oldPage["name"] as! String
                        
                        newRunePages.pages.append(newPage)
                    }
                    newRunePages.summonerId = oldRunePages["summonerId"] as! CLong
                    
                    newResponse[json.allKeys[i] as! String] = newRunePages
                }
                completion(newResponse)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
