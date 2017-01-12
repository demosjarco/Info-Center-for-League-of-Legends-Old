//
//  ChampionDetail_Content_Header.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/5/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit

protocol ChampViewHeaderDelegate {
    func goBack()
}

class ChampionDetail_Content_Header: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource {
    var delegate:ChampViewHeaderDelegate?
    var stats = StatsDto()
    
    @IBOutlet var championCover:UIImageView?
    @IBOutlet var championIcon:UIImageView?
    
    @IBAction func backButtonpressed() {
        self.delegate?.goBack()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champStatCell", for: indexPath) as! ChampionDetail_Content_Header_Stat_Cell
        
        switch indexPath.row {
        case 0:
            // Armor
            cell.statIcon?.image = UIImage(named: "FlatArmorMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.armor * 100) / 100)
            return cell
        case 1:
            // Armor per level
            cell.statIcon?.image = UIImage(named: "rFlatArmorModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.armorperlevel * 100) / 100)
            return cell
        case 2:
            // Attack damage
            cell.statIcon?.image = UIImage(named: "FlatPhysicalDamageMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.attackdamage * 100) / 100)
            return cell
        case 3:
            // Attack damage per level
            cell.statIcon?.image = UIImage(named: "rFlatPhysicalDamageModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.attackdamageperlevel * 100) / 100)
            return cell
        case 4:
            // Attack speed
            // NOTE: base attack speed = (0.625 / (1.0 + attackspeedoffset))
            cell.statIcon?.image = UIImage(named: "PercentAttackSpeedMod")
            cell.statValue?.text = String(format: "%.2f", (0.625 / (1.0 + round(self.stats.attackspeedoffset * 100) / 100)))
            return cell
        case 5:
            // Health
            cell.statIcon?.image = UIImage(named: "FlatHPPoolMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.hp * 100) / 100)
            return cell
        case 6:
            // Health per level
            cell.statIcon?.image = UIImage(named: "rFlatHPModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.hpperlevel * 100) / 100)
            return cell
        case 7:
            // Health regen
            cell.statIcon?.image = UIImage(named: "FlatHPRegenMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.hpregen * 100) / 100)
            return cell
        case 8:
            // Health regen per level
            cell.statIcon?.image = UIImage(named: "rFlatHPRegenModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.hpregenperlevel * 100) / 100)
            return cell
        case 9:
            // Movement speed
            cell.statIcon?.image = UIImage(named: "PercentMovementSpeedMod")
            cell.statValue?.text = String(format: "%.f", self.stats.movespeed)
            return cell
        case 10:
            // Mana
            cell.statIcon?.image = UIImage(named: "FlatMPPoolMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.mp * 100) / 100)
            return cell
        case 11:
            // Mana per level
            cell.statIcon?.image = UIImage(named: "rFlatMPModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.mpperlevel * 100) / 100)
            return cell
        case 12:
            // Mana regen
            cell.statIcon?.image = UIImage(named: "FlatMPRegenMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.mpregen * 100) / 100)
            return cell
        case 13:
            // Mana regen per level
            cell.statIcon?.image = UIImage(named: "rFlatMPRegenModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.mpregenperlevel * 100) / 100)
            return cell
        case 14:
            // Magic resist
            cell.statIcon?.image = UIImage(named: "FlatSpellBlockMod")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.spellblock * 100) / 100)
            return cell
        case 15:
            // Magic resist per level
            cell.statIcon?.image = UIImage(named: "rFlatSpellBlockModPerLevel")
            cell.statValue?.text = String(format: "%.2f", round(self.stats.spellblockperlevel * 100) / 100)
            return cell
        default:
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
