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
    func getTopChampsBySummonerId(summonerId: CLong, count: Int, completion: (championMasteryList: [ChampionMasteryDto]) -> Void, notFound: () -> Void, errorBlock: () -> Void) {
        Endpoints().championMastery_bySummonerId_topChampions(summonerId: String(summonerId), count: count) { (composedUrl) in
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
                completion(championMasteryList: championMasteryList)
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
