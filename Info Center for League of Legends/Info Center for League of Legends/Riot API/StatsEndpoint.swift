//
//  StatsEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class StatsEndpoint: NSObject {
    func getStatsSummaryBySummonerId(summonerId: CLong, completion: (summaryList: PlayerStatsSummaryListDto) -> Void, errorBlock: () -> Void) {
        Endpoints().stats_bySummoner_summary(summonerId: String(summonerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let statSummary = PlayerStatsSummaryListDto()
                    let json = responseObject as! NSDictionary
                    
                    let oldPlayerStatSummaries = json["playerStatSummaries"] as! NSArray
                    var newPlayerStatSummaries = [PlayerStatsSummaryDto]()
                    for i in 0 ..< oldPlayerStatSummaries.count {
                        autoreleasepool({ ()
                            let oldSummary = oldPlayerStatSummaries[i] as! NSDictionary
                            let newSummary = PlayerStatsSummaryDto()
                            
                            autoreleasepool({ ()
                                let oldAggregatedStats = oldSummary["aggregatedStats"] as! NSDictionary
                                let newAggregatedStats = AggregatedStatsDto()
                                
                                newAggregatedStats.totalChampionKills = oldAggregatedStats["totalChampionKills"] as? Int
                                newAggregatedStats.totalMinionKills = oldAggregatedStats["totalMinionKills"] as? Int
                                newAggregatedStats.totalTurretsKilled = oldAggregatedStats["totalTurretsKilled"] as? Int
                                
                                newSummary.aggregatedStats = newAggregatedStats
                            })
                            newSummary.losses = oldSummary["losses"] as! Int
                            newSummary.modifyDate = oldSummary["modifyDate"] as! CLong
                            newSummary.playerStatSummaryType = oldSummary["playerStatSummaryType"] as! String
                            newSummary.wins = oldSummary["wins"] as! Int
                            
                            newPlayerStatSummaries.append(newSummary)
                        })
                    }
                    
                    statSummary.playerStatSummaries = newPlayerStatSummaries
                    statSummary.summonerId = json["summonerId"] as! CLong
                    
                    completion(summaryList: statSummary)
                })
            }, failure: { (task, error) in
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
