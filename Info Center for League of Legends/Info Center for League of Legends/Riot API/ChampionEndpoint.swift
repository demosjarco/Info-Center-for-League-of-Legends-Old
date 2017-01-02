//
//  ChampionEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/2/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class ChampionEndpoint: NSObject {
    func getAllChampions(_ freeToPlay: Bool, completion: @escaping (_ championList: ChampionListDto) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().champions(freeToPlay ? "true" : "false") { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: [[String: AnyObject]]]
                let newChampionList = ChampionListDto()
                
                let oldChampions = json["champions"]!
                for oldChampion in oldChampions {
                    let newChampion = ChampionInfoDto()
                    
                    newChampion.active = oldChampion["active"] as! Bool
                    newChampion.botEnabled = oldChampion["botEnabled"] as! Bool
                    newChampion.botMmEnabled = oldChampion["botMmEnabled"] as! Bool
                    newChampion.freeToPlay = oldChampion["freeToPlay"] as! Bool
                    newChampion.champId = oldChampion["id"] as! CLong
                    newChampion.rankedPlayEnabled = oldChampion["rankedPlayEnabled"] as! Bool
                    
                    newChampionList.champions.append(newChampion)
                }
                
                completion(newChampionList)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
