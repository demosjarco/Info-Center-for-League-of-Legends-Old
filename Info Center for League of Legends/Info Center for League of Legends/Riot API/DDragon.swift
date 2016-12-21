//
//  DDragon.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import AFNetworking

class DDragon: NSObject {
    enum uiinterfaceIconType:String {
        case champion = "champion"
        case gold = "gold"
        case items = "items"
        case minion = "minion"
        case score = "score"
        case spells = "spells"
    }
    
    func getCDNurl(_ completion: @escaping (_ cdnUrl: String) -> Void) {
        AFHTTPSessionManager().get("http://ddragon.leagueoflegends.com/realms/" + Endpoints().getRegion() + ".json", parameters: nil, progress: nil, success: { (task, responseObject) in
            let dict = responseObject as! NSDictionary
            completion(dict["cdn"] as! String)
        }, failure: nil)
    }
    
    func getLatestDDragonVersion(_ dataType: String, completion: @escaping (_ version: String) -> Void) {
        AFHTTPSessionManager().get("http://ddragon.leagueoflegends.com/realms/" + Endpoints().getRegion() + ".json", parameters: nil, progress: nil, success: { (task, responseObject) in
            let dict = responseObject as! [String: AnyObject]
            completion(dict["n"]![dataType] as! String)
        }, failure: nil)
    }
    
    func getProfileIcon(_ profileIconId: Int, completion: @escaping (_ profileIconURL: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("profileicon", completion: { (version) in
                completion(URL(string: cdnUrl + "/" + version + "/img/profileicon/" + String(profileIconId) + ".png")!)
            })
        }
    }
    
    func getChampionSplashArt(_ fullImageName: String, skinNumber: Int, completion: @escaping (_ champSplashArtUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            completion(URL(string: cdnUrl + "/img/champion/splash/" + fullImageName.replacingOccurrences(of: ".png", with: "_" + String(skinNumber) + ".jpg"))!)
        }
    }
    func getChampionLoadingArt(_ fullImageName: String, skinNumber: Int, completion: @escaping (_ champLoadingArtUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            completion(URL(string: cdnUrl + "/img/champion/loading/" + fullImageName.replacingOccurrences(of: ".png", with: "_" + String(skinNumber) + ".jpg"))!)
        }
    }
    func getChampionSquareArt(_ fullImageName: String, completion: @escaping (_ champSquareArtUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("champion", completion: { (version) in
                completion(URL(string: cdnUrl + "/" + version + "/img/champion/" + fullImageName)!)
            })
        }
    }
    func getChampionPassiveArt(_ fullImageName: String, completion: @escaping (_ champPassiveArtUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("champion", completion: { (version) in
                completion(URL(string: cdnUrl + "/" + version + "/img/passive/" + fullImageName)!)
            })
        }
    }
    func getChampionAbilityArt(_ fullImageName: String, completion: @escaping (_ champAbilityArtUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("champion", completion: { (version) in
                completion(URL(string: cdnUrl + "/" + version + "/img/spell/" + fullImageName)!)
            })
        }
    }
    
    func getSummonerSpellIcon(_ fullImageName: String, completion: @escaping (_ spellIconUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("summoner", completion: { (version) in
                completion(URL(string: cdnUrl + "/" + version + "/img/spell/" + fullImageName)!)
            })
        }
    }
    
    func getItemIcon(_ itemId: Int?, completion: @escaping (_ itemIconUrl: URL) -> Void) {
        // Item 3637 is icon for empty icon slot
        // If itemId is not there, use id 3637
        var itemIdFinal = 3637
        if (itemId != nil) {
            itemIdFinal = itemId!
        }
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("item", completion: { (version) in
                completion(URL(string: cdnUrl + "/" + version + "/img/item/" + String(itemIdFinal) + ".png")!)
            })
        }
    }
    
    func getMasteryIcon(_ masteryId: Int, gray: Bool, completion: @escaping (_ masteryIconUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion("mastery", completion: { (version) in
                var grayText = ""
                if gray {
                    grayText = "gray_"
                }
                completion(URL(string: cdnUrl + "/" + version + "/img/mastery/" + grayText + String(masteryId) + ".png")!)
            })
        }
    }
    
    func getUserInterfaceIcons(_ type: uiinterfaceIconType, completion: @escaping (_ uiIconUrl: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            completion(URL(string: cdnUrl + "/5.5.1/img/ui/" + type.rawValue + ".png")!)
        }
    }
}
