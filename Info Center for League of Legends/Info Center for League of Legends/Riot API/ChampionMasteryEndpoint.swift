//
//  ChampionMasteryEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class ChampionMasteryEndpoint: NSObject {
    /**
     Get all champion mastery entries sorted by champion level (first) then number of champion points descending
     
     - parameter playerId: Summoner ID associated with the player
     */
    func getAllChampsBySummonerId(playerId: CLong, completion: @escaping (_ champions: [ChampionMasteryDto]) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().championMastery_bySummonerId_champions(playerId: String(playerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [[String: AnyObject]]
                var championMasteryList = [ChampionMasteryDto]()
                for championMastery in json {
                    let newChampionMastery = ChampionMasteryDto()
                    
                    newChampionMastery.championId = championMastery["championId"] as! CLong
                    newChampionMastery.championLevel = championMastery["championLevel"] as! Int
                    newChampionMastery.championPoints = championMastery["championPoints"] as! Int
                    newChampionMastery.championPointsSinceLastLevel = championMastery["championPointsSinceLastLevel"] as! CLong
                    newChampionMastery.championPointsUntilNextLevel = championMastery["championPointsUntilNextLevel"] as! CLong
                    newChampionMastery.chestGranted = championMastery["chestGranted"] as! Bool
                    newChampionMastery.lastPlayTime = championMastery["lastPlayTime"] as! CLong
                    newChampionMastery.playerId = championMastery["playerId"] as! CLong
                    
                    championMasteryList.append(newChampionMastery)
                }
                completion(championMasteryList.sorted(by: { (o1, o2) -> Bool in
                    return o1.championLevel == o2.championLevel ? (o1.championPoints > o2.championPoints) : (o1.championLevel > o2.championLevel)
                }))
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
    
    func getTopChampsBySummonerId(playerId: CLong, count: Int, completion: @escaping (_ championMasteryList: [ChampionMasteryDto]) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().championMastery_bySummonerId_topChampions(playerId: String(playerId), count: count) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                var championMasteryList = [ChampionMasteryDto]()
                let json = responseObject as! [[String: AnyObject]]
                for oldChampionMastery in json {
                    let newChampionMastery = ChampionMasteryDto()
                    
                    newChampionMastery.championId = oldChampionMastery["championId"] as! CLong
                    newChampionMastery.championLevel = oldChampionMastery["championLevel"] as! Int
                    newChampionMastery.championPoints = oldChampionMastery["championPoints"] as! Int
                    newChampionMastery.championPointsSinceLastLevel = oldChampionMastery["championPointsSinceLastLevel"] as! CLong
                    newChampionMastery.championPointsUntilNextLevel = oldChampionMastery["championPointsUntilNextLevel"] as! CLong
                    newChampionMastery.chestGranted = oldChampionMastery["chestGranted"] as! Bool
                    newChampionMastery.lastPlayTime = oldChampionMastery["lastPlayTime"] as! CLong
                    newChampionMastery.playerId = oldChampionMastery["playerId"] as! CLong
                    
                    championMasteryList.append(newChampionMastery)
                }
                completion(championMasteryList.sorted(by: { (o1, o2) -> Bool in
                    return o1.championLevel == o2.championLevel ? (o1.championPoints > o2.championPoints) : (o1.championLevel > o2.championLevel)
                }))
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
