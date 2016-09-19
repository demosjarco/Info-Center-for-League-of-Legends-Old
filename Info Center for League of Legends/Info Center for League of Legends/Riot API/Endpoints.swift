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
        return "https://" + getRegion() + ".api.pvp.net/api/lol/" + getRegion()
    }
    
    func getStaticDataBaseEndpoint() -> String {
        return "https://global.api.pvp.net/api/lol/static-data/" + getRegion() + "/v1.2/"
    }
    
    func getRegion() -> String {
        return UserDefaults.standard.string(forKey: "league_region")!
    }
    
    func getApiKey(completion: @escaping (_ apiKey:String) -> Void) {
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch(completionHandler: { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                
                completion(remoteConfig["apiKey"].stringValue!)
            }
        })
    }
    
    func optimalLocaleForRegion(completion: @escaping (_ optimalLocale: Bool) -> Void) {
        StaticDataEndpoint().getRegionValidLocales { (languages) in
            if languages.contains(Locale.autoupdatingCurrent.identifier)  {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Endpoint URLs
    
    // Champion Mastery
    func championMastery_bySummonerId_champions(playerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
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
            let urlString = "https://" + self.getRegion() + ".api.pvp.net/championmastery/location/" + region + "/player/" + playerId + "/champions" + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    func championMastery_bySummonerId_topChampions(playerId: String, count: Int, completion: @escaping (_ composedUrl: String) -> Void) {
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
            var urlString = "https://" + self.getRegion() + ".api.pvp.net/championmastery/location/" + region + "/player/" + playerId + "/topchampions"
            if count == 0 {
                urlString = urlString + "?api_key=" + apiKey
            } else {
                urlString = urlString + "?count=" + String(count) + "&api_key=" + apiKey
            }
            completion(urlString)
        }
    }
    
    // Game
    func game_BySummoner(summonerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.3/game/by-summoner/" + summonerId + "/recent?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // League
    func league_bySummoner_entry(summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v2.5/league/by-summoner/" + summonerIds + "/entry?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // Static Data
    func staticData_champion_id(championId: String, champData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion(completion: { (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "champion/" + championId
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&champData=" + champData + "&api_key=" + apiKey
                } else {
                    urlString += "?champData=" + champData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        }
    }
    
    func staticData_languages(completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getStaticDataBaseEndpoint() + "languages?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    func staticData_masteries(masteryListData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion(completion: { (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "mastery"
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&masteryListData=" + masteryListData + "&api_key=" + apiKey
                } else {
                    urlString += "?masteryListData=" + masteryListData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        }
    }
    
    func staticData_masteries_id(masteryId: String, masteryListData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion(completion: { (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "mastery/" + masteryId
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&masteryListData=" + masteryListData + "&api_key=" + apiKey
                } else {
                    urlString += "?masteryListData=" + masteryListData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        }
    }
    
    func staticData_summonerSpell_id(spellId: String, spellData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey(completion: { (apiKey) in
            self.optimalLocaleForRegion(completion: { (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "summoner-spell/" + spellId
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&spellData=" + spellData + "&api_key=" + apiKey
                } else {
                    urlString += "?spellData=" + spellData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        })
    }
    
    // Status
    func status_shards(completion: (_ composedUrl: String) -> Void) {
        let urlString = "http://status.leagueoflegends.com/shards"
        completion(urlString)
    }
    
    func status_byShard(completion: @escaping (_ composedUrl: String) -> Void) {
        let urlString = "http://status.leagueoflegends.com/shards/" + self.getRegion()
        completion(urlString)
    }
    
    // Stats
    func stats_bySummoner_summary(summonerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.3/stats/by-summoner/" + summonerId + "/summary?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // Summoner
    func summoner_byName(summonerNames: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/by-name/" + summonerNames + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    func summoner_byId(summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    func summoner_masteriesById(summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "/masteries?api_key=" + apiKey
            completion(urlString)
        }
    }
}
