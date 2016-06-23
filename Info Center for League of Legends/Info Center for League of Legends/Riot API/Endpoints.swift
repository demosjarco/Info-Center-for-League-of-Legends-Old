//
//  Endpoints.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/23/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase

class Endpoints: NSObject {
    func getRegion() -> String {
        return UserDefaults.standard().string(forKey: "league_region")!
    }
    
    func getApiKey(completion: (apiKey:String) -> Void) {
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch(completionHandler: { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                
                completion(apiKey: remoteConfig["apiKey"].stringValue!)
            }
        })
    }
    
    func summoner_byName(summonerNames: String) -> String {
        return "https://" + getRegion() + ".api.pvp.net/api/lol/" + getRegion() + "/v1.4/summoner/by-name/" + summonerNames
    }
}
