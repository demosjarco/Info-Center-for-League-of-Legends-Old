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
            if let value = child.value as? Int8 , value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
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
    
    func getApiKey(_ completion: @escaping (_ apiKey:String) -> Void) {
        let remoteConfig = FIRRemoteConfig.remoteConfig()
//        remoteConfig.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
        remoteConfig.fetch(completionHandler: { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                
                completion(remoteConfig["apiKey"].stringValue!)
            }
        })
    }
    
    func optimalLocaleForRegion(_ completion: @escaping (_ optimalLocale: Bool) -> Void) {
        StaticDataEndpoint().getRegionValidLocales { (languages) in
            if languages.contains(Locale.autoupdatingCurrent.identifier)  {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Endpoint URLs
    
    // Champions
    func champions(_ freeToPlay:String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.2/champion?freeToPlay=" + freeToPlay + "&api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // Champion Mastery
    func championMastery_bySummonerId_byChampionId(_ championId:String, playerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
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
            let urlString = "https://" + self.getRegion() + ".api.pvp.net/championmastery/location/" + region + "/player/" + playerId + "/champion/" + championId + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    func championMastery_bySummonerId_champions(_ playerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
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
    
    func championMastery_bySummonerId_topChampions(_ playerId: String, count: Int, completion: @escaping (_ composedUrl: String) -> Void) {
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
    
    // Current game
    func currentGame(_ summonerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
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
            let urlString = "https://" + self.getRegion() + ".api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/" + region + "/" + summonerId + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // Game
    func game_BySummoner(_ summonerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.3/game/by-summoner/" + summonerId + "/recent?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // League
    func league_bySummoner_entry(_ summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v2.5/league/by-summoner/" + summonerIds + "/entry?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // Static Data
    func staticData_champion_id(_ championId: String, champData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion({ (optimalLocale) in
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
    
    func staticData_languages(_ completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getStaticDataBaseEndpoint() + "languages?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    func staticData_masteries(_ masteryListData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion({ (optimalLocale) in
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
    
    func staticData_masteries_id(_ masteryId: String, masteryListData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion({ (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "mastery/" + masteryId
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&masteryData=" + masteryListData + "&api_key=" + apiKey
                } else {
                    urlString += "?masteryData=" + masteryListData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        }
    }
    
    func staticData_runes(_ runeListData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion({ (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "rune"
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&runeListData=" + runeListData + "&api_key=" + apiKey
                } else {
                    urlString += "?runeListData=" + runeListData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        }
    }
    
    func staticData_runes_id(_ runeId: String, runeListData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            self.optimalLocaleForRegion({ (optimalLocale) in
                var urlString = self.getStaticDataBaseEndpoint() + "rune/" + runeId
                if optimalLocale {
                    urlString += "?locale=" + Locale.autoupdatingCurrent.identifier + "&runeData=" + runeListData + "&api_key=" + apiKey
                } else {
                    urlString += "?runeData=" + runeListData + "&api_key=" + apiKey
                }
                completion(urlString)
            })
        }
    }
    
    func staticData_summonerSpell_id(_ spellId: String, spellData: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey({ (apiKey) in
            self.optimalLocaleForRegion({ (optimalLocale) in
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
    func status_shards(_ completion: (_ composedUrl: String) -> Void) {
        let urlString = "http://status.leagueoflegends.com/shards"
        completion(urlString)
    }
    
    func status_byShard(_ completion: @escaping (_ composedUrl: String) -> Void) {
        let urlString = "http://status.leagueoflegends.com/shards/" + self.getRegion()
        completion(urlString)
    }
    
    // Stats
    func stats_bySummoner_summary(_ summonerId: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.3/stats/by-summoner/" + summonerId + "/summary?api_key=" + apiKey
            completion(urlString)
        }
    }
    
    // Summoner
    func summoner_byName(_ summonerNames: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/by-name/" + summonerNames + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    func summoner_byId(_ summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "?api_key=" + apiKey
            completion(urlString)
        }
    }
    func summoner_masteriesById(_ summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "/masteries?api_key=" + apiKey
            completion(urlString)
        }
    }
    func summoner_runesById(_ summonerIds: String, completion: @escaping (_ composedUrl: String) -> Void) {
        self.getApiKey { (apiKey) in
            let urlString = self.getBaseEndpoint() + "/v1.4/summoner/" + summonerIds + "/runes?api_key=" + apiKey
            completion(urlString)
        }
    }
}
