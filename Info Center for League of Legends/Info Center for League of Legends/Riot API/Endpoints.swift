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
    enum platformId: String {
        case br = "BR1"
        case eune = "EUN1"
        case euw = "EUW1"
        case jp = "JP1"
        case kr = "KR"
        case lan = "LA1"
        case las = "LA2"
        case na = "NA1"
        case oce = "OC1"
        case ru = "RU"
        case tr = "TR1"
    }
    
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
    
    func getStaticDataBaseEndpoint() -> String {
        return "https://global.api.pvp.net/api/lol/static-data/" + self.getRegion() + "/v1.2/"
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
    
    func optimalLocaleForRegion(completion: (optimalLocale: Bool) -> Void) {
        StaticDataEndpoint().getRegionValidLocales { (languages) in
            if languages.contains(Locale.autoupdatingCurrent.localeIdentifier)  {
                completion(optimalLocale: true)
            } else {
                completion(optimalLocale: false)
            }
        }
    }
    
    // MARK: - Endpoint URLs
    
    // Champion Mastery
    func championMastery_bySummonerId_topChampions(summonerId: String, count: Int, completion: (composedUrl: String) -> Void) {
        autoreleasepool { ()
            var region:String
            switch self.getRegion() {
            case "br":
                region = platformId.br.rawValue
            case "eune":
                region = platformId.eune.rawValue
            case "euw":
                region = platformId.euw.rawValue
            case "jp":
                region = platformId.jp.rawValue
            case "kr":
                region = platformId.kr.rawValue
            case "lan":
                region = platformId.lan.rawValue
            case "las":
                region = platformId.las.rawValue
            case "na":
                region = platformId.na.rawValue
            case "oce":
                region = platformId.oce.rawValue
            case "ru":
                region = platformId.ru.rawValue
            case "tr":
                region = platformId.br.rawValue
            default:
                region = ""
            }
            
            self.getApiKey { (apiKey) in
                var urlString = "https://" + self.getRegion() + ".api.pvp.net/championmastery/location/" + region + "/player/" + summonerId + "/topchampions"
                if count == 0 {
                    urlString = urlString + "?api_key=" + apiKey
                } else {
                    urlString = urlString + "?count=" + String(count) + "&api_key=" + apiKey
                }
                completion(composedUrl: urlString)
            }
        }
    }
    
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
    
    func staticData_languages(completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getStaticDataBaseEndpoint() + "languages?api_key=" + apiKey
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
    func summoner_masteriesById(summonerIds: String, completion: (composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "/masteries?api_key=" + apiKey
            completion(composedUrl: urlString)
        }
    }
}
