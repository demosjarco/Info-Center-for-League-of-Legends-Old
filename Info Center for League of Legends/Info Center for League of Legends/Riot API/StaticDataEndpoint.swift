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
    
    func getChampionInfoById(champId: Int, championData: champData, completion: (ChampionDto) -> Void, notFound: () -> Void, error: () -> Void) {
        Endpoints().staticData_champion_id(championId: String(champId), champData: championData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let newChampion = ChampionDto()
                    let json = responseObject as! [String: AnyObject]
                    
                    if (json["allytips"] != nil) {
                        newChampion.allytips = json["allytips"] as! [String]
                    }
                    if (json["blurb"] != nil) {
                        newChampion.blurb = json["blurb"] as! String
                    }
                    if (json["enemytips"] != nil) {
                        newChampion.enemytips = json["enemytips"] as! [String]
                    }
                    newChampion.champId = json["id"] as! Int
                    if (json["image"] != nil) {
                        autoreleasepool({ ()
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
                        })
                    }
                    if (json["info"] != nil) {
                        autoreleasepool({ ()
                            let oldInfo = json["info"] as! [String: AnyObject]
                            let newInfo = InfoDto()
                            
                            newInfo.attack = oldInfo["attack"] as! Int
                            newInfo.defense = oldInfo["defense"] as! Int
                            newInfo.difficulty = oldInfo["difficulty"] as! Int
                            newInfo.magic = oldInfo["magic"] as! Int
                            
                            newChampion.info = newInfo
                        })
                    }
                    newChampion.key = json["key"] as! String
                    if (json["lore"] != nil) {
                        newChampion.lore = json["lore"] as! String
                    }
                    newChampion.name = json["name"] as! String
                    if (json["partype"] != nil) {
                        newChampion.partype = json["partype"] as! String
                    }
                    if (json["passive"] != nil) {
                        autoreleasepool({ ()
                            let oldPassive = json["passive"] as! [String: AnyObject]
                            let newPassive = PassiveDto()
                            
                            newPassive.rawDescription = oldPassive["description"] as! String
                            autoreleasepool({ ()
                                let oldImage = oldPassive["image"] as! [String: AnyObject]
                                
                                newPassive.image.full = oldImage["full"] as! String
                                newPassive.image.group = oldImage["group"] as! String
                                newPassive.image.h = oldImage["h"] as! Int
                                newPassive.image.sprite = oldImage["sprite"] as! String
                                newPassive.image.w = oldImage["w"] as! Int
                                newPassive.image.x = oldImage["x"] as! Int
                                newPassive.image.y = oldImage["y"] as! Int
                            })
                            newPassive.name = oldPassive["name"] as! String
                            newPassive.sanitizedDescription = oldPassive["sanitizedDescription"] as! String
                            
                            newChampion.passive = newPassive
                        })
                    }
                    if (json["recommended"] != nil) {
                        autoreleasepool({ ()
                            let oldRecommendedList = json["recommended"] as! [[String: AnyObject]]
                            var newRecommendedList = [RecommendedDto]()
                            
                            for oldRecommended in oldRecommendedList {
                                let newRecommended = RecommendedDto()
                                
                                let oldBlocks = oldRecommended["blocks"] as! [[String: AnyObject]]
                                for oldBlock in oldBlocks {
                                    autoreleasepool({ ()
                                        let newBlock = BlockDto()
                                        
                                        let oldItems = oldBlock["items"] as! [[String: AnyObject]]
                                        for oldItem in oldItems {
                                            autoreleasepool({ ()
                                                let newItem = BlockItemDto()
                                                
                                                newItem.count = oldItem["count"] as! Int
                                                newItem.itemId = oldItem["id"] as! Int
                                                
                                                newBlock.items.append(newItem)
                                            })
                                        }
                                        newBlock.recMath = oldBlock["recMath"] as! Bool
                                        newBlock.type = oldBlock["type"] as! String
                                        
                                        newRecommended.blocks.append(newBlock)
                                    })
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
                        })
                    }
                    if (json["skins"] != nil) {
                        autoreleasepool({ ()
                            let oldSkins = json["skins"] as! [[String: AnyObject]]
                            var newSkins = [SkinDto]()
                            
                            for oldSkin in oldSkins {
                                autoreleasepool({ ()
                                    let newSkin = SkinDto()
                                    
                                    newSkin.skinId = oldSkin["id"] as! Int
                                    newSkin.name = oldSkin["name"] as! String
                                    newSkin.num = oldSkin["num"] as! Int
                                    
                                    newSkins.append(newSkin)
                                })
                            }
                            
                            newChampion.skins = newSkins
                        })
                    }
                    if (json["spells"] != nil) {
                        autoreleasepool({ ()
                            let oldSpells = json["spells"] as! [[String: AnyObject]]
                            var newSpells = [ChampionSpellDto]()
                            
                            for oldSpell in oldSpells {
                                autoreleasepool({ ()
                                    let newSpell = ChampionSpellDto()
                                    
                                    autoreleasepool({ ()
                                        let oldAltImages = oldSpell["altimages"] as! [[String: AnyObject]]
                                        for oldAltImage in oldAltImages {
                                            autoreleasepool({ ()
                                                let newAltImage = ImageDto()
                                                
                                                newAltImage.full = oldAltImage["full"] as! String
                                                newAltImage.group = oldAltImage["group"] as! String
                                                newAltImage.h = oldAltImage["h"] as! Int
                                                newAltImage.sprite = oldAltImage["sprite"] as! String
                                                newAltImage.w = oldAltImage["w"] as! Int
                                                newAltImage.x = oldAltImage["x"] as! Int
                                                newAltImage.y = oldAltImage["y"] as! Int
                                                
                                                newSpell.altimages.append(newAltImage)
                                            })
                                        }
                                    })
                                    newSpell.cooldown = oldSpell["cooldown"] as! [Double]
                                    newSpell.cooldownBurn = oldSpell["cooldownBurn"] as! String
                                    newSpell.cost = oldSpell["cost"] as! [Int]
                                    newSpell.costBurn = oldSpell["costBurn"] as! String
                                    newSpell.costType = oldSpell["costType"] as! String
                                    newSpell.rawDescription = oldSpell["description"] as! String
//                                    newSpell.effect = oldSpell["<#key#>"] as! <#type#>
                                    newSpell.effectBurn = oldSpell["effectBurn"] as! [String]
                                    autoreleasepool({ ()
                                        let oldImage = oldSpell["image"] as! [String: AnyObject]
                                        
                                        newSpell.image.full = oldImage["full"] as! String
                                        newSpell.image.group = oldImage["group"] as! String
                                        newSpell.image.h = oldImage["h"] as! Int
                                        newSpell.image.sprite = oldImage["sprite"] as! String
                                        newSpell.image.w = oldImage["w"] as! Int
                                        newSpell.image.x = oldImage["x"] as! Int
                                        newSpell.image.y = oldImage["y"] as! Int
                                    })
                                    newSpell.key = oldSpell["key"] as! String
                                    autoreleasepool({ ()
                                        let oldLevelTip = oldSpell["leveltip"] as! [String: AnyObject]
                                        
                                        newSpell.leveltip.effect = oldLevelTip["effect"] as! [String]
                                        newSpell.leveltip.label = oldLevelTip["label"] as! [String]
                                    })
                                    newSpell.maxrank = oldSpell["maxrank"] as! Int
                                    newSpell.name = oldSpell["name"] as! String
                                    let oldRange = oldSpell["range"] as! [AnyObject]
                                    for range in oldRange {
                                        if String(range) == "self" {
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
                                        autoreleasepool({ ()
                                            let newVar = SpellVarsDto()
                                            
                                            newVar.coeff = oldVar["coeff"] as! [Double]
                                            newVar.dyn = oldVar["dyn"] as! String
                                            newVar.key = oldVar["key"] as! String
                                            newVar.link = oldVar["link"] as! String
                                            newVar.ranksWith = oldVar["ranksWith"] as! String
                                            
                                            newSpell.vars.append(newVar)
                                        })
                                    }
                                    
                                    newSpells.append(newSpell)
                                })
                            }
                            
                            newChampion.spells = newSpells
                        })
                    }
                    if (json["stats"] != nil) {
                        autoreleasepool({ ()
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
                        })
                    }
                    if (json["tags"] != nil) {
                        newChampion.tags = json["tags"] as! [String]
                    }
                    newChampion.title = json["title"] as! String
                    
                    completion(newChampion)
                })
            }, failure: { (task, error) in
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getRegionValidLocales(completion: (languages: [String]) -> Void) {
        Endpoints().staticData_languages { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let json = responseObject as! [String]
                    completion(languages: json)
                })
            }, failure: { (task, error) in
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
