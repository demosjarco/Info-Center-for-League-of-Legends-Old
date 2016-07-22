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
    func getRecentGamesBySummonerId(summonerId: CLong, completion: (recentGamesMap: RecentGamesDto) -> Void, errorBock: () -> Void) {
        Endpoints().game_BySummoner(summonerId: String(summonerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let recentGames = RecentGamesDto()
                    let json = responseObject as! NSDictionary
                    
                    autoreleasepool({ ()
                        let oldGames = json["games"] as! [[String: AnyObject]]
                        for oldGame in oldGames {
                            let newGame = GameDto()
                            
                            newGame.championId = oldGame["championId"] as! Int
                            newGame.createDate = NSDate(timeIntervalSince1970: (oldGame["createDate"] as! CLong) / 1000)
                            
                            newGame.gameId = oldGame["gameId"] as! CLong
                            newGame.gameMode = oldGame["gameMode"] as! String
                            newGame.gameType = oldGame["gameType"] as! String
                            
                            
                            recentGames.games.append(newGame)
                        }
                    })
                    recentGames.summonerId = json["summonerId"] as! CLong
                    
                    completion(recentGamesMap: recentGames)
                })
            }, failure: { (task, error) in
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
