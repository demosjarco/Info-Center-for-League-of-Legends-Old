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
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8 where value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        return identifier
    }
    
    func getBaseEndpoint() -> String {
        return "https://" + self.getRegion() + ".api.pvp.net/api/lol/" + self.getRegion()
    }
    
    func getRegion() -> String {
        return UserDefaults.standard.string(forKey: "league_region")!
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
    
    // MARK: - Endpoint URLs
    
    // Game
    func game_BySummoner(summonerId: String, completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.3/game/by-summoner/" + summonerId + "/recent?api_key=" + apiKey
            completion(composedUrl: urlString)
        }
    }
    
    // League
    func league_bySummoner_entry(summonerIds: String, completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v2.5/league/by-summoner/" + summonerIds + "/entry?api_key=" + apiKey
            completion(composedUrl: urlString)
        }
    }
    
    // Stats
    func stats_bySummoner_summary(summonerId: String, completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.3/stats/by-summoner/" + summonerId + "/summary?api_key=" + apiKey
            completion(composedUrl: urlString)
        }
    }
    
    // Summoner
    func summoner_byName(summonerNames: String, completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/by-name/" + summonerNames + "?api_key=" + apiKey
            completion(composedUrl: urlString)
        }
    }
    func summoner_byId(summonerIds: String, completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "?api_key=" + apiKey
            completion(composedUrl: urlString)
        }
    }
}
