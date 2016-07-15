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
    
    // League
    func league_bySummoner_entry(summonerIds: String) -> String {
        return "https://" + getRegion() + ".api.pvp.net/api/lol/" + getRegion() + "/v2.5/league/by-summoner/" + summonerIds + "/entry?api_key="
    }
    
    // Summoner
    func summoner_byName(summonerNames: String) -> String {
        return "https://" + getRegion() + ".api.pvp.net/api/lol/" + getRegion() + "/v1.4/summoner/by-name/" + summonerNames + "?api_key="
    }
    func summoner_byId(summonerIds: String) -> String {
        return "https://" + getRegion() + ".api.pvp.net/api/lol/" + getRegion() + "/v1.4/summoner/" + summonerIds + "?api_key="
    }
}
