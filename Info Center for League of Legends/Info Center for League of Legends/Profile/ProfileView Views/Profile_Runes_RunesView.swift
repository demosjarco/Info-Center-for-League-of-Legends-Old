//
//  Profile_Runes_RunesView.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/19/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit
import AMPopTip

class Profile_Runes_RunesView: MainCollectionViewController {
    var pageSelected = RunePageDto()
    var pageStats = [String: Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = self.pageSelected.name
        
        var count = pageSelected.slots.count
        for slot in pageSelected.slots {
            StaticDataEndpoint().getRuneInfoById(slot.runeId, runeData: .Stats, completion: { (rune) in
                if rune.stats.FlatArmorMod != 0.0 {
                    if (self.pageStats["FlatArmorMod"] != nil) {
                        self.pageStats["FlatArmorMod"]! += rune.stats.FlatArmorMod
                    } else {
                        self.pageStats["FlatArmorMod"] = rune.stats.FlatArmorMod
                    }
                }
                if rune.stats.FlatCritChanceMod != 0.0 {
                    if (self.pageStats["FlatCritChanceMod"] != nil) {
                        self.pageStats["FlatCritChanceMod"]! += rune.stats.FlatCritChanceMod
                    } else {
                        self.pageStats["FlatCritChanceMod"] = rune.stats.FlatCritChanceMod
                    }
                }
                if rune.stats.FlatCritDamageMod != 0.0 {
                    if (self.pageStats["FlatCritDamageMod"] != nil) {
                        self.pageStats["FlatCritDamageMod"]! += rune.stats.FlatCritDamageMod
                    } else {
                        self.pageStats["FlatCritDamageMod"] = rune.stats.FlatCritDamageMod
                    }
                }
                if rune.stats.FlatEnergyPoolMod != 0.0 {
                    if (self.pageStats["FlatEnergyPoolMod"] != nil) {
                        self.pageStats["FlatEnergyPoolMod"]! += rune.stats.FlatEnergyPoolMod
                    } else {
                        self.pageStats["FlatEnergyPoolMod"] = rune.stats.FlatEnergyPoolMod
                    }
                }
                if rune.stats.FlatEnergyRegenMod != 0.0 {
                    if (self.pageStats["FlatEnergyRegenMod"] != nil) {
                        self.pageStats["FlatEnergyRegenMod"]! += rune.stats.FlatEnergyRegenMod
                    } else {
                        self.pageStats["FlatEnergyRegenMod"] = rune.stats.FlatEnergyRegenMod
                    }
                }
                if rune.stats.FlatHPPoolMod != 0.0 {
                    if (self.pageStats["FlatHPPoolMod"] != nil) {
                        self.pageStats["FlatHPPoolMod"]! += rune.stats.FlatHPPoolMod
                    } else {
                        self.pageStats["FlatHPPoolMod"] = rune.stats.FlatHPPoolMod
                    }
                }
                if rune.stats.FlatHPRegenMod != 0.0 {
                    if (self.pageStats["FlatHPRegenMod"] != nil) {
                        self.pageStats["FlatHPRegenMod"]! += rune.stats.FlatHPRegenMod
                    } else {
                        self.pageStats["FlatHPRegenMod"] = rune.stats.FlatHPRegenMod
                    }
                }
                if rune.stats.FlatMagicDamageMod != 0.0 {
                    if (self.pageStats["FlatMagicDamageMod"] != nil) {
                        self.pageStats["FlatMagicDamageMod"]! += rune.stats.FlatMagicDamageMod
                    } else {
                        self.pageStats["FlatMagicDamageMod"] = rune.stats.FlatMagicDamageMod
                    }
                }
                if rune.stats.FlatMPPoolMod != 0.0 {
                    if (self.pageStats["FlatMPPoolMod"] != nil) {
                        self.pageStats["FlatMPPoolMod"]! += rune.stats.FlatMPPoolMod
                    } else {
                        self.pageStats["FlatMPPoolMod"] = rune.stats.FlatMPPoolMod
                    }
                }
                if rune.stats.FlatMPRegenMod != 0.0 {
                    if (self.pageStats["FlatMPRegenMod"] != nil) {
                        self.pageStats["FlatMPRegenMod"]! += rune.stats.FlatMPRegenMod
                    } else {
                        self.pageStats["FlatMPRegenMod"] = rune.stats.FlatMPRegenMod
                    }
                }
                if rune.stats.FlatPhysicalDamageMod != 0.0 {
                    if (self.pageStats["FlatPhysicalDamageMod"] != nil) {
                        self.pageStats["FlatPhysicalDamageMod"]! += rune.stats.FlatPhysicalDamageMod
                    } else {
                        self.pageStats["FlatPhysicalDamageMod"] = rune.stats.FlatPhysicalDamageMod
                    }
                }
                if rune.stats.FlatSpellBlockMod != 0.0 {
                    if (self.pageStats["FlatSpellBlockMod"] != nil) {
                        self.pageStats["FlatSpellBlockMod"]! += rune.stats.FlatSpellBlockMod
                    } else {
                        self.pageStats["FlatSpellBlockMod"] = rune.stats.FlatSpellBlockMod
                    }
                }
                if rune.stats.PercentAttackSpeedMod != 0.0 {
                    if (self.pageStats["PercentAttackSpeedMod"] != nil) {
                        self.pageStats["PercentAttackSpeedMod"]! += rune.stats.PercentAttackSpeedMod
                    } else {
                        self.pageStats["PercentAttackSpeedMod"] = rune.stats.PercentAttackSpeedMod
                    }
                }
                if rune.stats.PercentEXPBonus != 0.0 {
                    if (self.pageStats["PercentEXPBonus"] != nil) {
                        self.pageStats["PercentEXPBonus"]! += rune.stats.PercentEXPBonus
                    } else {
                        self.pageStats["PercentEXPBonus"] = rune.stats.PercentEXPBonus
                    }
                }
                if rune.stats.PercentHPPoolMod != 0.0 {
                    if (self.pageStats["PercentHPPoolMod"] != nil) {
                        self.pageStats["PercentHPPoolMod"]! += rune.stats.PercentHPPoolMod
                    } else {
                        self.pageStats["PercentHPPoolMod"] = rune.stats.PercentHPPoolMod
                    }
                }
                if rune.stats.PercentLifeStealMod != 0.0 {
                    if (self.pageStats["PercentLifeStealMod"] != nil) {
                        self.pageStats["PercentLifeStealMod"]! += rune.stats.PercentLifeStealMod
                    } else {
                        self.pageStats["PercentLifeStealMod"] = rune.stats.PercentLifeStealMod
                    }
                }
                if rune.stats.PercentMovementSpeedMod != 0.0 {
                    if (self.pageStats["PercentMovementSpeedMod"] != nil) {
                        self.pageStats["PercentMovementSpeedMod"]! += rune.stats.PercentMovementSpeedMod
                    } else {
                        self.pageStats["PercentMovementSpeedMod"] = rune.stats.PercentMovementSpeedMod
                    }
                }
                if rune.stats.PercentSpellVampMod != 0.0 {
                    if (self.pageStats["PercentSpellVampMod"] != nil) {
                        self.pageStats["PercentSpellVampMod"]! += rune.stats.PercentSpellVampMod
                    } else {
                        self.pageStats["PercentSpellVampMod"] = rune.stats.PercentSpellVampMod
                    }
                }
                if rune.stats.rFlatArmorModPerLevel != 0.0 {
                    if (self.pageStats["rFlatArmorModPerLevel"] != nil) {
                        self.pageStats["rFlatArmorModPerLevel"]! += rune.stats.rFlatArmorModPerLevel
                    } else {
                        self.pageStats["rFlatArmorModPerLevel"] = rune.stats.rFlatArmorModPerLevel
                    }
                }
                if rune.stats.rFlatArmorPenetrationMod != 0.0 {
                    if (self.pageStats["rFlatArmorPenetrationMod"] != nil) {
                        self.pageStats["rFlatArmorPenetrationMod"]! += rune.stats.rFlatArmorPenetrationMod
                    } else {
                        self.pageStats["rFlatArmorPenetrationMod"] = rune.stats.rFlatArmorPenetrationMod
                    }
                }
                if rune.stats.rFlatEnergyModPerLevel != 0.0 {
                    if (self.pageStats["rFlatEnergyModPerLevel"] != nil) {
                        self.pageStats["rFlatEnergyModPerLevel"]! += rune.stats.rFlatEnergyModPerLevel
                    } else {
                        self.pageStats["rFlatEnergyModPerLevel"] = rune.stats.rFlatEnergyModPerLevel
                    }
                }
                if rune.stats.rFlatEnergyRegenModPerLevel != 0.0 {
                    if (self.pageStats["rFlatEnergyRegenModPerLevel"] != nil) {
                        self.pageStats["rFlatEnergyRegenModPerLevel"]! += rune.stats.rFlatEnergyRegenModPerLevel
                    } else {
                        self.pageStats["rFlatEnergyRegenModPerLevel"] = rune.stats.rFlatEnergyRegenModPerLevel
                    }
                }
                if rune.stats.rFlatGoldPer10Mod != 0.0 {
                    if (self.pageStats["rFlatGoldPer10Mod"] != nil) {
                        self.pageStats["rFlatGoldPer10Mod"]! += rune.stats.rFlatGoldPer10Mod
                    } else {
                        self.pageStats["rFlatGoldPer10Mod"] = rune.stats.rFlatGoldPer10Mod
                    }
                }
                if rune.stats.rFlatHPModPerLevel != 0.0 {
                    if (self.pageStats["rFlatHPModPerLevel"] != nil) {
                        self.pageStats["rFlatHPModPerLevel"]! += rune.stats.rFlatHPModPerLevel
                    } else {
                        self.pageStats["rFlatHPModPerLevel"] = rune.stats.rFlatHPModPerLevel
                    }
                }
                if rune.stats.rFlatHPRegenModPerLevel != 0.0 {
                    if (self.pageStats["rFlatHPRegenModPerLevel"] != nil) {
                        self.pageStats["rFlatHPRegenModPerLevel"]! += rune.stats.rFlatHPRegenModPerLevel
                    } else {
                        self.pageStats["rFlatHPRegenModPerLevel"] = rune.stats.rFlatHPRegenModPerLevel
                    }
                }
                if rune.stats.rFlatMagicDamageModPerLevel != 0.0 {
                    if (self.pageStats["rFlatMagicDamageModPerLevel"] != nil) {
                        self.pageStats["rFlatMagicDamageModPerLevel"]! += rune.stats.rFlatMagicDamageModPerLevel
                    } else {
                        self.pageStats["rFlatMagicDamageModPerLevel"] = rune.stats.rFlatMagicDamageModPerLevel
                    }
                }
                if rune.stats.rFlatMagicPenetrationMod != 0.0 {
                    if (self.pageStats["rFlatMagicPenetrationMod"] != nil) {
                        self.pageStats["rFlatMagicPenetrationMod"]! += rune.stats.rFlatMagicPenetrationMod
                    } else {
                        self.pageStats["rFlatMagicPenetrationMod"] = rune.stats.rFlatMagicPenetrationMod
                    }
                }
                if rune.stats.rFlatMPModPerLevel != 0.0 {
                    if (self.pageStats["rFlatMPModPerLevel"] != nil) {
                        self.pageStats["rFlatMPModPerLevel"]! += rune.stats.rFlatMPModPerLevel
                    } else {
                        self.pageStats["rFlatMPModPerLevel"] = rune.stats.rFlatMPModPerLevel
                    }
                }
                if rune.stats.rFlatMPRegenModPerLevel != 0.0 {
                    if (self.pageStats["rFlatMPRegenModPerLevel"] != nil) {
                        self.pageStats["rFlatMPRegenModPerLevel"]! += rune.stats.rFlatMPRegenModPerLevel
                    } else {
                        self.pageStats["rFlatMPRegenModPerLevel"] = rune.stats.rFlatMPRegenModPerLevel
                    }
                }
                if rune.stats.rFlatPhysicalDamageModPerLevel != 0.0 {
                    if (self.pageStats["rFlatPhysicalDamageModPerLevel"] != nil) {
                        self.pageStats["rFlatPhysicalDamageModPerLevel"]! += rune.stats.rFlatPhysicalDamageModPerLevel
                    } else {
                        self.pageStats["rFlatPhysicalDamageModPerLevel"] = rune.stats.rFlatPhysicalDamageModPerLevel
                    }
                }
                if rune.stats.rFlatSpellBlockModPerLevel != 0.0 {
                    if (self.pageStats["rFlatSpellBlockModPerLevel"] != nil) {
                        self.pageStats["rFlatSpellBlockModPerLevel"]! += rune.stats.rFlatSpellBlockModPerLevel
                    } else {
                        self.pageStats["rFlatSpellBlockModPerLevel"] = rune.stats.rFlatSpellBlockModPerLevel
                    }
                }
                if rune.stats.rPercentCooldownMod != 0.0 {
                    if (self.pageStats["rPercentCooldownMod"] != nil) {
                        self.pageStats["rPercentCooldownMod"]! += rune.stats.rPercentCooldownMod
                    } else {
                        self.pageStats["rPercentCooldownMod"] = rune.stats.rPercentCooldownMod
                    }
                }
                if rune.stats.rPercentCooldownModPerLevel != 0.0 {
                    if (self.pageStats["rPercentCooldownModPerLevel"] != nil) {
                        self.pageStats["rPercentCooldownModPerLevel"]! += rune.stats.rPercentCooldownModPerLevel
                    } else {
                        self.pageStats["rPercentCooldownModPerLevel"] = rune.stats.rPercentCooldownModPerLevel
                    }
                }
                if rune.stats.rPercentTimeDeadMod != 0.0 {
                    if (self.pageStats["rPercentTimeDeadMod"] != nil) {
                        self.pageStats["rPercentTimeDeadMod"]! += rune.stats.rPercentTimeDeadMod
                    } else {
                        self.pageStats["rPercentTimeDeadMod"] = rune.stats.rPercentTimeDeadMod
                    }
                }
                
                count -= 1
                if count == 0 {
                    self.collectionView?.reloadSections(IndexSet(integer: 0))
                }
            }, notFound: {
                // ???
                count -= 1
                if count == 0 {
                    self.collectionView?.reloadSections(IndexSet(integer: 0))
                }
            }, errorBlock: {
                // Error
                count -= 1
                if count == 0 {
                    self.collectionView?.reloadSections(IndexSet(integer: 0))
                }
            })
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pageStats.values.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "runeStatCell", for: indexPath) as! ProfileView_Rune_StatsCell
        // Performance
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.layer.shouldRasterize = true
        
        cell.runeIcon?.image = UIImage(named: Array(self.pageStats.keys)[indexPath.row])
        if Array(self.pageStats.values)[indexPath.row] >= 0.0 {
            cell.runeStat?.text = "+" + String(format: "%.2f", Array(self.pageStats.values)[indexPath.row])
        } else {
            cell.runeStat?.text = String(format: "%.2f", Array(self.pageStats.values)[indexPath.row])
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let popTip = AMPopTip()
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)!
        let cellRect = collectionView.convert(attributes.frame, to: self.view)
        
        popTip.borderWidth = 2
        popTip.borderColor = UIColor(red: 70.0/255.0, green: 55.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        popTip.popoverColor = UIColor(red: 1.0/255.0, green: 10.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        popTip.textAlignment = .center
        
        var runeType = ""
        switch Array(self.pageStats.keys)[indexPath.row] {
        case "FlatArmorMod":
            runeType = "Armor"
            break
        case "FlatCritChanceMod":
            runeType = "Critical Chance"
            break
        case "FlatCritDamageMod":
            runeType = "Critical Damage"
            break
        case "FlatEnergyPoolMod":
            runeType = "Energy"
            break
        case "FlatEnergyRegenMod":
            runeType = "Energy Regeneration"
            break
        case "FlatHPPoolMod":
            runeType = "Health"
            break
        case "FlatHPRegenMod":
            runeType = "Health Regeneration"
            break
        case "FlatMagicDamageMod":
            runeType = "Ability Power"
            break
        case "FlatMPPoolMod":
            runeType = "Mana"
            break
        case "FlatMPRegenMod":
            runeType = "Mana Regeneration"
            break
        case "FlatPhysicalDamageMod":
            runeType = "Attack Damage"
            break
        case "FlatSpellBlockMod":
            runeType = "Magic Resist"
            break
        case "PercentAttackSpeedMod":
            runeType = "Attack Speed"
            break
        case "PercentEXPBonus":
            runeType = "Experience"
            break
        case "PercentHPPoolMod":
            runeType = "Percent Health"
            break
        case "PercentLifeStealMod":
            runeType = "Life Steal"
            break
        case "PercentMovementSpeedMod":
            runeType = "Movement Speed"
            break
        case "PercentSpellVampMod":
            runeType = "Spell Vamp"
            break
        case "rFlatArmorModPerLevel":
            runeType = "Scaling Armor"
            break
        case "rFlatArmorPenetrationMod":
            runeType = "Lethality"
            break
        case "rFlatEnergyModPerLevel":
            runeType = "Scaling Energy"
            break
        case "rFlatEnergyRegenModPerLevel":
            runeType = "Scaling Energy Regeneration"
            break
        case "rFlatGoldPer10Mod":
            runeType = "Gold"
            break
        case "rFlatHPModPerLevel":
            runeType = "Scaling Health"
            break
        case "rFlatHPRegenModPerLevel":
            runeType = "Scaling Health Regeneration"
            break
        case "rFlatMagicDamageModPerLevel":
            runeType = "Scaling Ability Power"
            break
        case "rFlatMagicPenetrationMod":
            runeType = "Magic Penetration"
            break
        case "rFlatMPModPerLevel":
            runeType = "Scaling Mana"
            break
        case "rFlatMPRegenModPerLevel":
            runeType = "Scaling Mana Regeneration"
            break
        case "rFlatPhysicalDamageModPerLevel":
            runeType = "Scaling Attack Damage"
            break
        case "rFlatSpellBlockModPerLevel":
            runeType = "Scaling Magic Resist"
            break
        case "rPercentCooldownMod":
            runeType = "Cooldown Reduction"
            break
        case "rPercentCooldownModPerLevel":
            runeType = "Scaling Cooldown Reduction"
            break
        case "rPercentTimeDeadMod":
            runeType = "Revival"
            break
        default:
            break
        }
        popTip.showText(runeType, direction: AMPopTipDirection.down, maxWidth: self.view.frame.size.width * 0.8, in: self.view, fromFrame: cellRect)
    }
}
