//
//  GameEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/21/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class GameEndpoint: NSObject {
    func getRecentGamesBySummonerId(summonerId: CLong, completion: (recentGamesMap: RecentGamesDto) -> Void, errorBlock: () -> Void) {
        Endpoints().game_BySummoner(summonerId: String(summonerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let recentGames = RecentGamesDto()
                let json = responseObject as! NSDictionary
                
                let oldGames = json["games"] as! [[String: AnyObject]]
                for oldGame in oldGames {
                    let newGame = GameDto()
                    
                    newGame.championId = oldGame["championId"] as! Int
                    // newGame.createDate = NSDate(timeIntervalSince1970: (oldGame["createDate"] as! CLong) / 1000)
                    // newGame.fellowPlayers
                    newGame.gameId = oldGame["gameId"] as! CLong
                    newGame.gameMode = oldGame["gameMode"] as! String
                    newGame.gameType = oldGame["gameType"] as! String
                    newGame.invalid = oldGame["invalid"] as! Bool
                    newGame.ipEarned = oldGame["ipEarned"] as! Int
                    newGame.level = oldGame["level"] as! Int
                    newGame.mapId = oldGame["mapId"] as! Int
                    newGame.spell1 = oldGame["spell1"] as! Int
                    newGame.spell2 = oldGame["spell2"] as! Int
                    
                    let newStats = newGame.stats
                    let oldStats = oldGame["stats"] as! [String: AnyObject]
                    
                    newStats.assists = oldStats["assists"] as? Int
                    
                    
                    newStats.championsKilled = oldStats["championsKilled"] as? Int
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    newStats.numDeaths = oldStats["numDeaths"] as? Int
                    newStats.win = oldStats["win"] as! Bool
                    
                    newGame.stats = newStats
                    
                    newGame.subType = oldGame["subType"] as! String
                    newGame.teamId = oldGame["teamId"] as! Int
                    
                    recentGames.games.append(newGame)
                }
                recentGames.summonerId = json["summonerId"] as! CLong
                
                completion(recentGamesMap: recentGames)
            }, failure: { (task, error) in
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
