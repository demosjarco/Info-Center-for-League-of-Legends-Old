//
//  CurrentGameEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class CurrentGameEndpoint: NSObject {
    
    /**
     Get current game information for the given summoner ID.
     */
    func getSpectatorGameInfo(_ summonerId: CLong, completion: @escaping (_ game: CurrentGameInfo) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().currentGame(String(summonerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let game = CurrentGameInfo()
                
                let oldBannedChampions = json["bannedChampions"] as! [[String: AnyObject]]
                for oldBannedChampion in oldBannedChampions {
                    let newBannedChampion = BannedChampion()
                    
                    newBannedChampion.championId = oldBannedChampion["championId"] as! CLong
                    newBannedChampion.pickTurn = oldBannedChampion["pickTurn"] as! Int
                    newBannedChampion.teamId = oldBannedChampion["teamId"] as! CLong
                    
                    game.bannedChampions.append(newBannedChampion)
                }
                
                game.gameId = json["gameId"] as! CLong
                game.gameLength = json["gameLength"] as! CLong
                game.gameMode = json["gameMode"] as! String
                game.gameQueueConfigId = json["gameQueueConfigId"] as! CLong
                
                let epochSec = json["gameStartTime"] as! CLong / CLong(1000)
                game.gameStartTime = Date(timeIntervalSince1970: TimeInterval(epochSec))
                
                game.gameType = json["gameType"] as! String
                game.mapId = json["mapId"] as! CLong
                
                let oldObservers = json["observers"] as! [String: String]
                game.observers.encryptionKey = oldObservers["encryptionKey"]!
                
                let oldParticipants = json["participants"] as! [[String: AnyObject]]
                for oldParticipant in oldParticipants {
                    let newParticipant = CurrentGameParticipant()
                    
                    newParticipant.bot = oldParticipant["bot"] as! Bool
                    newParticipant.championId = oldParticipant["championId"] as! CLong
                    
                    let oldMasteries = oldParticipant["masteries"] as! [[String: AnyObject]]
                    for oldMastery in oldMasteries {
                        let newMastery = MasteryDto()
                        
                        newMastery.masteryId = oldMastery["masteryId"] as! Int
                        newMastery.rank = oldMastery["rank"] as! Int
                        
                        newParticipant.masteries.append(newMastery)
                    }
                    
                    newParticipant.profileIconId = oldParticipant["profileIconId"] as! CLong
                    // runes
                    newParticipant.spell1Id = oldParticipant["spell1Id"] as! CLong
                    newParticipant.spell2Id = oldParticipant["spell2Id"] as! CLong
                    newParticipant.summonerId = oldParticipant["summonerId"] as! CLong
                    newParticipant.summonerName = oldParticipant["summonerName"] as! String
                    newParticipant.teamId = oldParticipant["teamId"] as! CLong
                    
                    game.participants.append(newParticipant)
                }
                
                game.platformId = json["platformId"] as! String
                
                completion(game)
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
}
