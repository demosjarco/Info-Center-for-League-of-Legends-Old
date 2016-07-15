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
    
    func getLeagueEntryBySummonerIds(summonerIds: [CLong], completion: (summonerMap: [String: [LeagueDto]]) -> Void, notFound: () -> Void, errorBlock: () -> Void) {
        Endpoints().league_bySummoner_entry(summonerIds: NSArray(array: summonerIds).value(forKey: "description").componentsJoined(by: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    var newDict = [String: [LeagueDto]]()
                    let json = responseObject as! NSDictionary
                    for h in 0 ..< json.count {
                        var leagueArray = [LeagueDto]()
                        let summoner = json.allValues[h] as! NSArray
                        for i in 0 ..< summoner.count {
                            let oldLeague = summoner[i] as! NSDictionary
                            
                            let newLeague = LeagueDto()
                            autoreleasepool({ ()
                                var newEntries = [LeagueEntryDto]()
                                let oldEntries = oldLeague["entries"] as! NSArray
                                for j in 0 ..< oldEntries.count {
                                    let oldEntry = oldEntries[j] as! NSDictionary
                                    
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
                            if oldLeague["participantId"] != nil {
                                newLeague.participantId = oldLeague["participantId"] as? String
                            }
                            newLeague.queue = oldLeague["queue"] as! String
                            newLeague.tier = oldLeague["tier"] as! String
                            
                            leagueArray.append(newLeague)
                        }
                        newDict[json.allKeys[h] as! String] = leagueArray
                    }
                    completion(summonerMap: newDict)
                })
            }, failure: { (task, error) in
                if error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode == 404 {
                    notFound()
                } else {
                    errorBlock()
                    FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                }
            })
        }
    }
}
