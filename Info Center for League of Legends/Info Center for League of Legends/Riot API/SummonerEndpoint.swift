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
    func getSummonersForSummonerNames(summonerNames: [String], completion: @escaping (summonerMap: [String: SummonerDto]) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        // Standardize names
        let standardizedSummonerNames = NSMutableArray()
        for summonerName:String in summonerNames {
            standardizedSummonerNames.add(summonerName.replacingOccurrences(of: " ", with: "").lowercased())
        }
        
        Endpoints().summoner_byName(summonerNames: standardizedSummonerNames.value(forKey: "description").componentsJoined(by: ",")) { (composedUrl) in
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
                completion(summonerMap: newDict)
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
    
    func getSummonersForIds(summonerIds: [CLong], completion: @escaping (summonerMap: [String: SummonerDto]) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().summoner_byId(summonerIds: NSArray(array: summonerIds).value(forKey: "description").componentsJoined(by: ",")) { (composedUrl) in
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
                completion(summonerMap: newDict)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getMasteriesForSummonerIds(summonerIds: [CLong], completion: @escaping (summonerMap: [String: MasteryPagesDto]) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().summoner_masteriesById(summonerIds: NSArray(array: summonerIds).value(forKey: "description").componentsJoined(by: ",")) { (composedUrl) in
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
                completion(summonerMap: newResponse)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
