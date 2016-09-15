//
//  StaticDataEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class StaticDataEndpoint: NSObject {
    enum champData:String {
        case All = "all"
        case AllyTips = "allytips"
        case AltImages = "altimages"
        case Blurb = "blurb"
        case EnemyTips = "enemytips"
        case Image = "image"
        case Info = "info"
        case Lore = "lore"
        case Partype = "partype"
        case Passive = "passive"
        case RecommendedItems = "recommended"
        case Skins = "skins"
        case Spells = "spells"
        case Stats = "stats"
        case Tags = "tags"
    }
    
    enum masteryListData:String {
        case All = "all"
        case Image = "image"
        case MasteryTree = "masteryTree"
        case Prerequisite = "prereq"
        case Ranks = "ranks"
        case SanitizedDescription = "sanitizedDescription"
        case Tree = "tree"
    }
    
    enum spellData:String {
        case all = "all"
        case cooldown = "cooldown"
        case cooldownBurn = "cooldownBurn"
        case cost = "cost"
        case costBurn = "costBurn"
        case costType = "costType"
        case effect = "effect"
        case effectBurn = "effectBurn"
        case image = "image"
        case key = "key"
        case levelTip = "leveltip"
        case maxRank = "maxrank"
        case modes = "modes"
        case range = "range"
        case rangeBurn = "rangeBurn"
        case resource = "resource"
        case sanitizedDescription = "sanitizedDescription"
        case sanitizedTooltip = "sanitizedTooltip"
        case tooltip = "tooltip"
        case vars = "vars"
    }
    
    func getChampionInfoById(champId: Int, championData: champData, completion: @escaping (ChampionDto) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_champion_id(championId: String(champId), champData: championData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let newChampion = ChampionDto()
                let json = responseObject as! [String: AnyObject]
                
                if (json["allytips"] != nil) {
                    newChampion.allytips = json["allytips"] as? [String]
                }
                if (json["blurb"] != nil) {
                    newChampion.blurb = json["blurb"] as? String
                }
                if (json["enemytips"] != nil) {
                    newChampion.enemytips = json["enemytips"] as? [String]
                }
                newChampion.champId = json["id"] as! Int
                if (json["image"] != nil) {
                    let oldImage = json["image"] as! [String: AnyObject]
                    let newImage = ImageDto()
                    
                    newImage.full = oldImage["full"] as! String
                    newImage.group = oldImage["group"] as! String
                    newImage.h = oldImage["h"] as! Int
                    newImage.sprite = oldImage["sprite"] as! String
                    newImage.w = oldImage["w"] as! Int
                    newImage.x = oldImage["x"] as! Int
                    newImage.y = oldImage["y"] as! Int
                    
                    newChampion.image = newImage
                }
                if (json["info"] != nil) {
                    let oldInfo = json["info"] as! [String: AnyObject]
                    let newInfo = InfoDto()
                    
                    newInfo.attack = oldInfo["attack"] as! Int
                    newInfo.defense = oldInfo["defense"] as! Int
                    newInfo.difficulty = oldInfo["difficulty"] as! Int
                    newInfo.magic = oldInfo["magic"] as! Int
                    
                    newChampion.info = newInfo
                }
                newChampion.key = json["key"] as! String
                if (json["lore"] != nil) {
                    newChampion.lore = json["lore"] as? String
                }
                newChampion.name = json["name"] as! String
                if (json["partype"] != nil) {
                    newChampion.partype = json["partype"] as? String
                }
                if (json["passive"] != nil) {
                    let oldPassive = json["passive"] as! [String: AnyObject]
                    let newPassive = PassiveDto()
                    
                    newPassive.rawDescription = oldPassive["description"] as! String
                    let oldImage = oldPassive["image"] as! [String: AnyObject]
                    
                    newPassive.image.full = oldImage["full"] as! String
                    newPassive.image.group = oldImage["group"] as! String
                    newPassive.image.h = oldImage["h"] as! Int
                    newPassive.image.sprite = oldImage["sprite"] as! String
                    newPassive.image.w = oldImage["w"] as! Int
                    newPassive.image.x = oldImage["x"] as! Int
                    newPassive.image.y = oldImage["y"] as! Int
                    newPassive.name = oldPassive["name"] as! String
                    newPassive.sanitizedDescription = oldPassive["sanitizedDescription"] as! String
                    
                    newChampion.passive = newPassive
                }
                if (json["recommended"] != nil) {
                    let oldRecommendedList = json["recommended"] as! [[String: AnyObject]]
                    var newRecommendedList = [RecommendedDto]()
                    
                    for oldRecommended in oldRecommendedList {
                        let newRecommended = RecommendedDto()
                        
                        let oldBlocks = oldRecommended["blocks"] as! [[String: AnyObject]]
                        for oldBlock in oldBlocks {
                            let newBlock = BlockDto()
                            
                            let oldItems = oldBlock["items"] as! [[String: AnyObject]]
                            for oldItem in oldItems {
                                let newItem = BlockItemDto()
                                
                                newItem.count = oldItem["count"] as! Int
                                newItem.itemId = oldItem["id"] as! Int
                                
                                newBlock.items.append(newItem)
                            }
                            newBlock.recMath = oldBlock["recMath"] as! Bool
                            newBlock.type = oldBlock["type"] as! String
                            
                            newRecommended.blocks.append(newBlock)
                        }
                        newRecommended.champion = oldRecommended["champion"] as! String
                        newRecommended.map = oldRecommended["map"] as! String
                        newRecommended.mode = oldRecommended["mode"] as! String
                        newRecommended.priority = oldRecommended["priority"] as! Bool
                        newRecommended.title = oldRecommended["title"] as! String
                        newRecommended.type = oldRecommended["type"] as! String
                        
                        newRecommendedList.append(newRecommended)
                    }
                    
                    newChampion.recommended = newRecommendedList
                }
                if (json["skins"] != nil) {
                    let oldSkins = json["skins"] as! [[String: AnyObject]]
                    var newSkins = [SkinDto]()
                    
                    for oldSkin in oldSkins {
                        let newSkin = SkinDto()
                        
                        newSkin.skinId = oldSkin["id"] as! Int
                        newSkin.name = oldSkin["name"] as! String
                        newSkin.num = oldSkin["num"] as! Int
                        
                        newSkins.append(newSkin)
                    }
                    
                    newChampion.skins = newSkins
                }
                if (json["spells"] != nil) {
                    let oldSpells = json["spells"] as! [[String: AnyObject]]
                    var newSpells = [ChampionSpellDto]()
                    
                    for oldSpell in oldSpells {
                        let newSpell = ChampionSpellDto()
                        
                        let oldAltImages = oldSpell["altimages"] as! [[String: AnyObject]]
                        for oldAltImage in oldAltImages {
                            let newAltImage = ImageDto()
                            
                            newAltImage.full = oldAltImage["full"] as! String
                            newAltImage.group = oldAltImage["group"] as! String
                            newAltImage.h = oldAltImage["h"] as! Int
                            newAltImage.sprite = oldAltImage["sprite"] as! String
                            newAltImage.w = oldAltImage["w"] as! Int
                            newAltImage.x = oldAltImage["x"] as! Int
                            newAltImage.y = oldAltImage["y"] as! Int
                            
                            newSpell.altimages.append(newAltImage)
                        }
                        newSpell.cooldown = oldSpell["cooldown"] as! [Double]
                        newSpell.cooldownBurn = oldSpell["cooldownBurn"] as! String
                        newSpell.cost = oldSpell["cost"] as! [Int]
                        newSpell.costBurn = oldSpell["costBurn"] as! String
                        newSpell.costType = oldSpell["costType"] as! String
                        newSpell.rawDescription = oldSpell["description"] as! String
                        let oldEffects = oldSpell["effect"] as! NSArray
                        for oldEffect in oldEffects {
                            switch oldEffect {
                            case is NSNull:
                                newSpell.effect.append([Double]())
                                break
                            default:
                                newSpell.effect.append(oldEffect as! [Double])
                                break
                            }
                        }
                        newSpell.effectBurn = oldSpell["effectBurn"] as! [String]
                        let oldImage = oldSpell["image"] as! [String: AnyObject]
                        
                        newSpell.image.full = oldImage["full"] as! String
                        newSpell.image.group = oldImage["group"] as! String
                        newSpell.image.h = oldImage["h"] as! Int
                        newSpell.image.sprite = oldImage["sprite"] as! String
                        newSpell.image.w = oldImage["w"] as! Int
                        newSpell.image.x = oldImage["x"] as! Int
                        newSpell.image.y = oldImage["y"] as! Int
                        newSpell.key = oldSpell["key"] as! String
                        let oldLevelTip = oldSpell["leveltip"] as! [String: AnyObject]
                        
                        newSpell.leveltip.effect = oldLevelTip["effect"] as! [String]
                        newSpell.leveltip.label = oldLevelTip["label"] as! [String]
                        newSpell.maxrank = oldSpell["maxrank"] as! Int
                        newSpell.name = oldSpell["name"] as! String
                        let oldRange = oldSpell["range"] as! [AnyObject]
                        for range in oldRange {
                            if String(describing: range) == "self" {
                                // Self ability - set as 0
                                newSpell.range.append(0)
                            } else {
                                // Int
                                newSpell.range.append(range as! Int)
                            }
                        }
                        newSpell.rangeBurn = oldSpell["rangeBurn"] as! String
                        newSpell.resource = oldSpell["resource"] as! String
                        newSpell.sanitizedDescription = oldSpell["sanitizedDescription"] as! String
                        newSpell.sanitizedTooltip = oldSpell["sanitizedTooltip"] as! String
                        newSpell.tooltip = oldSpell["tooltip"] as! String
                        let oldVars = oldSpell["vars"] as! [[String: AnyObject]]
                        for oldVar in oldVars {
                            let newVar = SpellVarsDto()
                            
                            newVar.coeff = oldVar["coeff"] as! [Double]
                            newVar.dyn = oldVar["dyn"] as! String
                            newVar.key = oldVar["key"] as! String
                            newVar.link = oldVar["link"] as! String
                            newVar.ranksWith = oldVar["ranksWith"] as! String
                            
                            newSpell.vars.append(newVar)
                        }
                        
                        newSpells.append(newSpell)
                    }
                    
                    newChampion.spells = newSpells
                }
                if (json["stats"] != nil) {
                    let oldStats = json["stats"] as! [String: AnyObject]
                    let newStats = StatsDto()
                    
                    newStats.armor = oldStats["armor"] as! Double
                    newStats.armorperlevel = oldStats["armorperlevel"] as! Double
                    newStats.attackdamage = oldStats["attackdamage"] as! Double
                    newStats.attackdamageperlevel = oldStats["attackdamageperlevel"] as! Double
                    newStats.attackrange = oldStats["attackrange"] as! Double
                    newStats.attackspeedoffset = oldStats["attackspeedoffset"] as! Double
                    newStats.attackspeedperlevel = oldStats["attackspeedperlevel"] as! Double
                    newStats.crit = oldStats["crit"] as! Double
                    newStats.critperlevel = oldStats["critperlevel"] as! Double
                    newStats.hp = oldStats["hp"] as! Double
                    newStats.hpperlevel = oldStats["hpperlevel"] as! Double
                    newStats.hpregen = oldStats["hpregen"] as! Double
                    newStats.hpregenperlevel = oldStats["hpregenperlevel"] as! Double
                    newStats.movespeed = oldStats["movespeed"] as! Double
                    newStats.mp = oldStats["mp"] as! Double
                    newStats.mpperlevel = oldStats["mpperlevel"] as! Double
                    newStats.mpregen = oldStats["mpregen"] as! Double
                    newStats.mpregenperlevel = oldStats["mpregenperlevel"] as! Double
                    newStats.spellblock = oldStats["spellblock"] as! Double
                    newStats.spellblockperlevel = oldStats["spellblockperlevel"] as! Double
                    
                    newChampion.stats = newStats
                }
                if (json["tags"] != nil) {
                    newChampion.tags = json["tags"] as? [String]
                }
                newChampion.title = json["title"] as! String
                
                completion(newChampion)
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
    
    func getRegionValidLocales(completion: @escaping (languages: [String]) -> Void) {
        Endpoints().staticData_languages { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String]
                completion(json)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getMasteryInfo(masteryListData: masteryListData, completion: @escaping (masteryList: MasteryListDto) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_masteries(masteryListData: masteryListData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let newMasteryList = MasteryListDto()
                
                let data = json["data"] as! [String: AnyObject]
                for masteryName in data.keys {
                    let oldMastery = data[masteryName] as! [String: AnyObject]
                    let newMastery = SC_MasteryDto()
                    
                    newMastery.masteryDescription = oldMastery["description"] as! [String]
                    newMastery.masteryId = oldMastery["id"] as! Int
                    if oldMastery["image"] != nil {
                        let oldImage = oldMastery["image"] as! [String: AnyObject]
                        let newImage = ImageDto()
                        
                        newImage.full = oldImage["full"] as! String
                        newImage.group = oldImage["group"] as! String
                        newImage.h = oldImage["h"] as! Int
                        newImage.sprite = oldImage["sprite"] as! String
                        newImage.w = oldImage["w"] as! Int
                        newImage.x = oldImage["x"] as! Int
                        newImage.y = oldImage["y"] as! Int
                        
                        newMastery.image = newImage
                    }
                    if oldMastery["masteryTree"] != nil {
                        newMastery.masteryTree = oldMastery["masteryTree"] as? String
                    }
                    newMastery.name = oldMastery["name"] as! String
                    if (oldMastery["prereq"] != nil) {
                        newMastery.prereq = oldMastery["prereq"] as? String
                    }
                    if (oldMastery["ranks"] != nil) {
                        newMastery.ranks = oldMastery["ranks"] as? Int
                    }
                    if (oldMastery["sanitizedDescription"] != nil) {
                        newMastery.sanitizedDescription = oldMastery["sanitizedDescription"] as? [String]
                    }
                    
                    newMasteryList.data[masteryName] = newMastery
                }
                if json["tree"] != nil {
                    let oldTree = json["tree"] as! [String: AnyObject]
                    let newTree = MasteryTreeDto()
                    
                    let oldCunning = oldTree["Cunning"] as! [[AnyObject]]
                    for oldColumn in oldCunning {
                        let newColumn = MasteryTreeListDto()
                        
                        for oldMastery1 in oldColumn {
                            let newMastery = MasteryTreeItemDto()
                            switch oldMastery1 {
                            case is NSNull:
                                newMastery.masteryId = 0
                                break
                            default:
                                newMastery.masteryId = oldMastery1["masteryId"] as! Int
                                newMastery.prereq = oldMastery1["prereq"] as! String
                                break
                            }
                            
                            newColumn.masteryTreeItems.append(newMastery)
                        }
                        
                        newTree.cunning.append(newColumn)
                    }
                    
                    let oldFerocity = oldTree["Ferocity"] as! [[AnyObject]]
                    for oldColumn in oldFerocity {
                        let newColumn = MasteryTreeListDto()
                        
                        for oldMastery1 in oldColumn {
                            let newMastery = MasteryTreeItemDto()
                            switch oldMastery1 {
                            case is NSNull:
                                newMastery.masteryId = 0
                                break
                            default:
                                newMastery.masteryId = oldMastery1["masteryId"] as! Int
                                newMastery.prereq = oldMastery1["prereq"] as! String
                                break
                            }
                            
                            newColumn.masteryTreeItems.append(newMastery)
                        }
                        
                        newTree.ferocity.append(newColumn)
                    }

                    let oldResolve = oldTree["Resolve"] as! [[AnyObject]]
                    for oldColumn in oldResolve {
                        let newColumn = MasteryTreeListDto()
                        
                        for oldMastery1 in oldColumn {
                            let newMastery = MasteryTreeItemDto()
                            switch oldMastery1 {
                            case is NSNull:
                                newMastery.masteryId = 0
                                break
                            default:
                                newMastery.masteryId = oldMastery1["masteryId"] as! Int
                                newMastery.prereq = oldMastery1["prereq"] as! String
                                break
                            }
                            
                            newColumn.masteryTreeItems.append(newMastery)
                        }
                        
                        newTree.resolve.append(newColumn)
                    }
                }
                newMasteryList.type = json["type"] as! String
                newMasteryList.version = json["version"] as! String
                
                completion(masteryList: newMasteryList)
            }, failure: { (task, error) in
                errorBlock()
                let response = task!.response as! HTTPURLResponse
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getMasteryInfoById(masteryId: Int, masteryListData: masteryListData, completion: () -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_masteries_id(masteryId: String(masteryId), masteryListData: masteryListData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                //
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
    
    func getSpellInfoById(spellId: Int, spellData: spellData, completion: @escaping (spellInfo: SummonerSpellDto) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_summonerSpell_id(spellId: String(spellId), spellData: spellData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let info = SummonerSpellDto()
                
                if json["cooldown"] != nil {
                    info.cooldown = json["cooldown"] as? [Double]
                }
                if json["cooldownBurn"] != nil {
                    info.cooldownBurn = json["cooldownBurn"] as? String
                }
                if json["cost"] != nil {
                    info.cost = json["cost"] as? [Int]
                }
                if json["costBurn"] != nil {
                    info.costBurn = json["costBurn"] as? String
                }
                if json["costType"] != nil {
                    info.costType = json["costType"] as? String
                }
                info.spellDescription = json["description"] as! String
                if json["effect"] != nil {
                    let oldEffects = json["effect"] as! [AnyObject]
                    var newEffects = [[Double]]()
                    for oldEffect in oldEffects {
                        switch oldEffect {
                        case is NSNull:
                            newEffects.append([Double]())
                            break
                        default:
                            newEffects.append(oldEffect as! [Double])
                            break
                        }
                        info.effect = newEffects
                    }
                }
                if json["effectBurn"] != nil {
                    info.effectBurn = json["effectBurn"] as? [String]
                }
                info.spellId = json["id"] as! Int
                if json["image"] != nil {
                    let oldImage = json["image"] as! [String: AnyObject]
                    let newImage = ImageDto()
                    
                    newImage.full = oldImage["full"] as! String
                    newImage.group = oldImage["group"] as! String
                    newImage.h = oldImage["h"] as! Int
                    newImage.sprite = oldImage["sprite"] as! String
                    newImage.w = oldImage["w"] as! Int
                    newImage.x = oldImage["x"] as! Int
                    newImage.y = oldImage["y"] as! Int
                    
                    info.image = newImage
                }
                info.key = json["key"] as! String
                if json["leveltip"] != nil {
                    let oldLevelTip = json["leveltip"] as! [String: AnyObject]
                    let newLevelTip = LevelTipDto()
                    
                    newLevelTip.effect = oldLevelTip["effect"] as! [String]
                    newLevelTip.label = oldLevelTip["label"] as! [String]
                    info.leveltip = newLevelTip
                }
                if json["maxrank"] != nil {
                    info.maxrank = json["maxrank"] as? Int
                }
                if json["modes"] != nil {
                    info.modes = json["modes"] as? [String]
                }
                info.name = json["name"] as! String
                if json["range"] != nil {
                    let oldRange = json["range"] as! [AnyObject]
                    var newRange = [Int]()
                    for range in oldRange {
                        if String(range) == "self" {
                            // Self ability - set as 0
                            newRange.append(0)
                        } else {
                            // Int
                            newRange.append(range as! Int)
                        }
                    }
                    info.range = newRange
                }
                if json["rangeBurn"] != nil {
                    info.rangeBurn = json["rangeBurn"] as? String
                }
                if json["resource"] != nil {
                    info.resource = json["resource"] as? String
                }
                if json["sanitizedDescription"] != nil {
                    info.sanitizedDescription = json["sanitizedDescription"] as? String
                }
                if json["sanitizedTooltip"] != nil {
                    info.sanitizedTooltip = json["sanitizedTooltip"] as? String
                }
                info.summonerLevel = json["summonerLevel"] as! Int
                if json["tooltip"] != nil {
                    info.tooltip = json["tooltip"] as? String
                }
                if json["vars"] != nil {
                    let oldVars = json["vars"] as! [[String: AnyObject]]
                    var newVars = [SpellVarsDto]()
                    for oldVar in oldVars {
                        let newVar = SpellVarsDto()
                        
                        newVar.coeff = oldVar["coeff"] as! [Double]
                        newVar.dyn = oldVar["dyn"] as! String
                        newVar.key = oldVar["key"] as! String
                        newVar.link = oldVar["link"] as! String
                        newVar.ranksWith = oldVar["ranksWith"] as! String
                        
                        newVars.append(newVar)
                    }
                    info.vars = newVars
                }
                
                completion(spellInfo: info)
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
