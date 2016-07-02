//
//  LeagueEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/2/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class LeagueEndpoint: NSObject {
    func tierToNumber(tier: String) -> Int {
        switch tier {
        case "CHALLENGER":
            return 0
        case "MASTER":
            return 1
        case "DIAMOND":
            return 2
        case "PLATINUM":
            return 3
        case "GOLD":
            return 4
        case "SILVER":
            return 5
        default:
            return 6
        }
    }
    
    func romanNumeralToNumber(romanNumeral: String) -> Int {
        switch romanNumeral {
        case "I":
            return 1
        case "II":
            return 2
        case "III":
            return 3
        case "IV":
            return 4
        default:
            return 5
        }
    }
    
    func getLeagueEntryBySummonerIds(summonerIds: [CLong], completion: (summonerMap: [String: LeagueDto]) -> Void, notFound: () -> Void, errorBlock: () -> Void) {
        Endpoints().getApiKey { (apiKey) in
            let url = Endpoints().league_bySummoner_entry(summonerIds: NSArray(array: summonerIds).value(forKey: "description").componentsJoined(by: ",")).appending(apiKey)
            
            AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    var newDict = [String: LeagueDto]()
                    let dict = responseObject as! NSDictionary
                    let dictValues = dict.allValues as! [[String: AnyObject]]
                    for i in 0 ..< dictValues.count {
                        let oldLeague = dictValues[i]
                        
                        let newLeague = LeagueDto()
                        autoreleasepool({ ()
                            var newEntries = [LeagueEntryDto]()
                            let oldEntries = oldLeague["entries"] as! [[String: AnyObject]]
                            for j in 0 ..< oldEntries.count {
                                let oldEntry = oldEntries[j]
                                
                                let newEntry = LeagueEntryDto()
                                newEntry.division = oldEntry["division"] as! String
                                newEntry.isFreshBlood = oldEntry["isFreshBlood"] as! Bool
                                newEntry.isHotStreak = oldEntry["isHotStreak"] as! Bool
                                newEntry.isInactive = oldEntry["isInactive"] as! Bool
                                newEntry.isVeteran = oldEntry["isVeteran"] as! Bool
                                newEntry.leaguePoints = oldEntry["leaguePoints"] as! Int
                                newEntry.losses = oldEntry["losses"] as! Int
                                if oldEntry["miniSeries"] != nil {
                                    autoreleasepool({ ()
                                        let oldMiniSeries = oldEntry["miniSeries"] as! [String: AnyObject]
                                        
                                        let newMiniSeries = MiniSeriesDto()
                                        newMiniSeries.progress = oldMiniSeries["progress"] as! String
                                        newMiniSeries.target = oldMiniSeries["target"] as! Int
                                        newMiniSeries.losses = oldMiniSeries["losses"] as! Int
                                        newMiniSeries.wins = oldMiniSeries["wins"] as! Int
                                        
                                        newEntry.miniSeries = newMiniSeries
                                    })
                                }
                                newEntry.playerOrTeamId = oldEntry["playerOrTeamId"] as! String
                                newEntry.playerOrTeamName = oldEntry["playerOrTeamName"] as! String
                                newEntry.wins = oldEntry["wins"] as! Int
                                
                                newEntries.append(newEntry)
                            }
                            newLeague.entries = newEntries
                        })
                        newLeague.name = oldLeague["name"] as! String
                        newLeague.participantId = oldLeague["participantId"] as! String
                        newLeague.queue = oldLeague["queue"] as! String
                        newLeague.tier = oldLeague["tier"] as! String
                        
                        newDict[dict.allKeys[i] as! String] = newLeague
                    }
                    completion(summonerMap: newDict)
                })
                }, failure: { (task, error) in
                    if error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode == 404 {
                        notFound()
                    } else {
                        errorBlock()
                        FIRAnalytics.logEvent(withName: "api_eror", parameters: ["httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "endpoint": "summoner", "subEndpoint": "by-name", "region": Endpoints().getRegion(), "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                    }
            })
        }
    }
}
