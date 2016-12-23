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
    
    enum runeListData:String {
        case All = "all"
        case Colloq = "colloq"
        case ConsumeOnFull = "consumeOnFull"
        case Consumed = "consumed"
        case Depth = "depth"
        case From = "from"
        case Gold = "gold"
        case HideFromAll = "hideFromAll"
        case Image = "image"
        case InStore = "inStore"
        case Into = "into"
        case Maps = "maps"
        case RequiredChampion = "requiredChampion"
        case SanitizedDescription = "sanitizedDescription"
        case SpecialRecipe = "specialRecipe"
        case Stacks = "stacks"
        case Stats = "stats"
        case Tags = "tags"
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
    
    func getChampionInfoById(_ champId: Int, championData: champData, completion: @escaping (ChampionDto) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_champion_id(String(champId), champData: championData.rawValue) { (composedUrl) in
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
                        if oldRecommended["priority"] != nil {
                            newRecommended.priority = oldRecommended["priority"] as! Bool
                        }
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
                        
                        if oldSpell["altimages"] != nil {
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
                        if oldSpell["vars"] != nil {
                            let oldVars = oldSpell["vars"] as! [[String: AnyObject]]
                            for oldVar in oldVars {
                                let newVar = SpellVarsDto()
                                
                                newVar.coeff = oldVar["coeff"] as! [Double]
                                if oldVar["dyn"] != nil {
                                    newVar.dyn = oldVar["dyn"] as! String
                                }
                                newVar.key = oldVar["key"] as! String
                                newVar.link = oldVar["link"] as! String
                                if oldVar["ranksWith"] != nil {
                                    newVar.ranksWith = oldVar["ranksWith"] as! String
                                }
                                
                                newSpell.vars.append(newVar)
                            }
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
    
    func getRegionValidLocales(_ completion: @escaping (_ languages: [String]) -> Void) {
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
    
    func getMasteryInfo(_ masteryListData: masteryListData, completion: @escaping (_ masteryList: MasteryListDto) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_masteries(masteryListData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let newMasteryList = MasteryListDto()
                
                let data = json["data"] as! [String: AnyObject]
                for masteryName in data.keys {
                    let oldMastery = data[masteryName] as! [String: AnyObject]
                    let newMastery = SC_MasteryDto()
                    
                    newMastery.masteryId = oldMastery["id"] as! Int
                    newMastery.masteryDescription = oldMastery["description"] as! [String]
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
                    
                    let oldCunning = oldTree["Cunning"] as! [[String: [[String: AnyObject]]]]
                    for oldColumn in oldCunning {
                        let newColumn = MasteryTreeListDto()
                        
                        for oldMastery1 in oldColumn["masteryTreeItems"]! {
                            let newMastery = MasteryTreeItemDto()
                            
                            newMastery.masteryId = oldMastery1["masteryId"] as! Int
                            newMastery.prereq = oldMastery1["prereq"] as! String
                            
                            newColumn.masteryTreeItems.append(newMastery)
                        }
                        
                        newTree.cunning.append(newColumn)
                    }
                    
                    let oldFerocity = oldTree["Ferocity"] as! [[String: [[String: AnyObject]]]]
                    for oldColumn in oldFerocity {
                        let newColumn = MasteryTreeListDto()
                        
                        for oldMastery1 in oldColumn["masteryTreeItems"]! {
                            let newMastery = MasteryTreeItemDto()
                            
                            newMastery.masteryId = oldMastery1["masteryId"] as! Int
                            newMastery.prereq = oldMastery1["prereq"] as! String
                            
                            newColumn.masteryTreeItems.append(newMastery)
                        }
                        
                        newTree.ferocity.append(newColumn)
                    }

                    let oldResolve = oldTree["Resolve"] as! [[String: [[String: AnyObject]]]]
                    for oldColumn in oldResolve {
                        let newColumn = MasteryTreeListDto()
                        
                        for oldMastery1 in oldColumn["masteryTreeItems"]! {
                            let newMastery = MasteryTreeItemDto()
                            
                            newMastery.masteryId = oldMastery1["masteryId"] as! Int
                            newMastery.prereq = oldMastery1["prereq"] as! String
                            
                            newColumn.masteryTreeItems.append(newMastery)
                        }
                        
                        newTree.resolve.append(newColumn)
                    }
                    
                    newMasteryList.tree = newTree
                }
                newMasteryList.type = json["type"] as! String
                newMasteryList.version = json["version"] as! String
                
                completion(newMasteryList)
            }, failure: { (task, error) in
                errorBlock()
                let response = task!.response as! HTTPURLResponse
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getMasteryInfoById(_ masteryId: Int, masteryListData: masteryListData, completion: () -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_masteries_id(String(masteryId), masteryListData: masteryListData.rawValue) { (composedUrl) in
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
    
    func getRuneInfo(_ runeListData: runeListData, completion: @escaping (_ runeList: RuneListDto) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_runes(runeListData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                
            }, failure: { (task, error) in
                errorBlock()
                let response = task!.response as! HTTPURLResponse
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getRuneInfoById(_ runeId: Int, runeData: runeListData, completion: @escaping (_ rune: RuneDto) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_runes_id(String(runeId), runeListData: runeData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let newRune = RuneDto()
                
                newRune.runeId = json["id"] as! Int
                newRune.name = json["name"] as! String
                newRune.runeDescription = json["description"] as! String
                if (json["sanitizedDescription"] != nil) {
                    newRune.sanitizedDescription = json["sanitizedDescription"] as! String
                }
                if (json["tags"] != nil) {
                    newRune.tags = json["tags"] as! [String]
                }
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
                    
                    newRune.image = newImage
                }
                if (json["stats"] != nil) {
                    let oldStats = json["stats"] as! [String:Double]
                    
                    if oldStats.values.count == 0 {
                        // If no stats, assume lethality runes
                        switch json["id"] as! Int {
                        case 5009:
                            // Lesser Mark of Lethality
                            newRune.stats.rFlatArmorPenetrationMod = 0.90
                            break
                        case 5099:
                            // Lesser Quintessence of Lethality
                            newRune.stats.rFlatArmorPenetrationMod = 1.78
                            break
                        case 5131:
                            // Mark of Lethality
                            newRune.stats.rFlatArmorPenetrationMod = 1.25
                            break
                        case 5221:
                            // Quintessence of Lethality
                            newRune.stats.rFlatArmorPenetrationMod = 2.49
                            break
                        case 5253:
                            // Greater Mark of Lethality
                            newRune.stats.rFlatArmorPenetrationMod = 1.60
                            break
                        case 5343:
                            // Greater Quintessence of Lethality
                            newRune.stats.rFlatArmorPenetrationMod = 3.20
                            break
                        default:
                            break
                        }
                    } else {
                        if (oldStats["FlatArmorMod"] != nil) {
                            newRune.stats.FlatArmorMod = oldStats["FlatArmorMod"]!
                        }
                        if (oldStats["FlatCritChanceMod"] != nil) {
                            newRune.stats.FlatCritChanceMod = oldStats["FlatCritChanceMod"]!
                        }
                        if (oldStats["FlatCritDamageMod"] != nil) {
                            newRune.stats.FlatCritDamageMod = oldStats["FlatCritDamageMod"]!
                        }
                        if (oldStats["FlatEnergyPoolMod"] != nil) {
                            newRune.stats.FlatEnergyPoolMod = oldStats["FlatEnergyPoolMod"]!
                        }
                        if (oldStats["FlatEnergyRegenMod"] != nil) {
                            newRune.stats.FlatEnergyRegenMod = oldStats["FlatEnergyRegenMod"]!
                        }
                        if (oldStats["FlatHPPoolMod"] != nil) {
                            newRune.stats.FlatHPPoolMod = oldStats["FlatHPPoolMod"]!
                        }
                        if (oldStats["FlatHPRegenMod"] != nil) {
                            newRune.stats.FlatHPRegenMod = oldStats["FlatHPRegenMod"]!
                        }
                        if (oldStats["FlatMagicDamageMod"] != nil) {
                            newRune.stats.FlatMagicDamageMod = oldStats["FlatMagicDamageMod"]!
                        }
                        if (oldStats["FlatMPPoolMod"] != nil) {
                            newRune.stats.FlatMPPoolMod = oldStats["FlatMPPoolMod"]!
                        }
                        if (oldStats["FlatMPRegenMod"] != nil) {
                            newRune.stats.FlatMPRegenMod = oldStats["FlatMPRegenMod"]!
                        }
                        if (oldStats["FlatPhysicalDamageMod"] != nil) {
                            newRune.stats.FlatPhysicalDamageMod = oldStats["FlatPhysicalDamageMod"]!
                        }
                        if (oldStats["FlatSpellBlockMod"] != nil) {
                            newRune.stats.FlatSpellBlockMod = oldStats["FlatSpellBlockMod"]!
                        }
                        if (oldStats["PercentAttackSpeedMod"] != nil) {
                            newRune.stats.PercentAttackSpeedMod = oldStats["PercentAttackSpeedMod"]!
                        }
                        if (oldStats["PercentEXPBonus"] != nil) {
                            newRune.stats.PercentEXPBonus = oldStats["PercentEXPBonus"]!
                        }
                        if (oldStats["PercentHPPoolMod"] != nil) {
                            newRune.stats.PercentHPPoolMod = oldStats["PercentHPPoolMod"]!
                        }
                        if (oldStats["PercentLifeStealMod"] != nil) {
                            newRune.stats.PercentLifeStealMod = oldStats["PercentLifeStealMod"]!
                        }
                        if (oldStats["PercentMovementSpeedMod"] != nil) {
                            newRune.stats.PercentMovementSpeedMod = oldStats["PercentMovementSpeedMod"]!
                        }
                        if (oldStats["PercentSpellVampMod"] != nil) {
                            newRune.stats.PercentSpellVampMod = oldStats["PercentSpellVampMod"]!
                        }
                        if (oldStats["rFlatArmorModPerLevel"] != nil) {
                            newRune.stats.rFlatArmorModPerLevel = oldStats["rFlatArmorModPerLevel"]!
                        }
                        if (oldStats["rFlatArmorPenetrationMod"] != nil) {
                            newRune.stats.rFlatArmorPenetrationMod = oldStats["rFlatArmorPenetrationMod"]!
                        }
                        if (oldStats["rFlatEnergyModPerLevel"] != nil) {
                            newRune.stats.rFlatEnergyModPerLevel = oldStats["rFlatEnergyModPerLevel"]!
                        }
                        if (oldStats["rFlatEnergyRegenModPerLevel"] != nil) {
                            newRune.stats.rFlatEnergyRegenModPerLevel = oldStats["rFlatEnergyRegenModPerLevel"]!
                        }
                        if (oldStats["rFlatGoldPer10Mod"] != nil) {
                            newRune.stats.rFlatGoldPer10Mod = oldStats["rFlatGoldPer10Mod"]!
                        }
                        if (oldStats["rFlatHPModPerLevel"] != nil) {
                            newRune.stats.rFlatHPModPerLevel = oldStats["rFlatHPModPerLevel"]!
                        }
                        if (oldStats["rFlatHPRegenModPerLevel"] != nil) {
                            newRune.stats.rFlatHPRegenModPerLevel = oldStats["rFlatHPRegenModPerLevel"]!
                        }
                        if (oldStats["rFlatMagicDamageModPerLevel"] != nil) {
                            newRune.stats.rFlatMagicDamageModPerLevel = oldStats["rFlatMagicDamageModPerLevel"]!
                        }
                        if (oldStats["rFlatMagicPenetrationMod"] != nil) {
                            newRune.stats.rFlatMagicPenetrationMod = oldStats["rFlatMagicPenetrationMod"]!
                        }
                        if (oldStats["rFlatMPModPerLevel"] != nil) {
                            newRune.stats.rFlatMPModPerLevel = oldStats["rFlatMPModPerLevel"]!
                        }
                        if (oldStats["rFlatMPRegenModPerLevel"] != nil) {
                            newRune.stats.rFlatMPRegenModPerLevel = oldStats["rFlatMPRegenModPerLevel"]!
                        }
                        if (oldStats["rFlatPhysicalDamageModPerLevel"] != nil) {
                            newRune.stats.rFlatPhysicalDamageModPerLevel = oldStats["rFlatPhysicalDamageModPerLevel"]!
                        }
                        if (oldStats["rFlatSpellBlockModPerLevel"] != nil) {
                            newRune.stats.rFlatSpellBlockModPerLevel = oldStats["rFlatSpellBlockModPerLevel"]!
                        }
                        if (oldStats["rPercentCooldownMod"] != nil) {
                            newRune.stats.rPercentCooldownMod = oldStats["rPercentCooldownMod"]!
                        }
                        if (oldStats["rPercentCooldownModPerLevel"] != nil) {
                            newRune.stats.rPercentCooldownModPerLevel = oldStats["rPercentCooldownModPerLevel"]!
                        }
                        if (oldStats["rPercentTimeDeadMod"] != nil) {
                            newRune.stats.rPercentTimeDeadMod = oldStats["rPercentTimeDeadMod"]!
                        }
                    }
                }
                
                completion(newRune)
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
    
    func getSpellInfoById(_ spellId: Int, spellData: spellData, completion: @escaping (_ spellInfo: SummonerSpellDto) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().staticData_summonerSpell_id(String(spellId), spellData: spellData.rawValue) { (composedUrl) in
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
                        if String(describing: range) == "self" {
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
                
                completion(info)
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
