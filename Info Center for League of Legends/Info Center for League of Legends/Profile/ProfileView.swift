//
//  ProfileView.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate {
    func showParticiapantProfileInfo(_ summoner: SummonerDto)
}

class ProfileView: MainCollectionViewController, HeaderDelegate, RecentGames_SummaryTileDelegate {
    var delegate:ProfileViewDelegate?
    var summoner = SummonerDto()
    
    var profileHeader = ProfileView_Header()
    
    // Champion Mastery
    var cm_top3champs = [ChampionMasteryDto]()
    
    // Recent Games
    var rc_totalGames = 0
    var rc_gamesWon = 0
    var rc_lastGame = GameDto()
    
    // Masteries
    var mas_currentPage = MasteryPageDto()
    
    // Runes
    var run_currentPage = RunePageDto()
    var run_currentPage_stats = [String: Double]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoreleasepool(invoking: { ()
            // Layout
            let oldLayout = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
            let strechyLayout = StretchyHeaderCollectionViewLayout()
            strechyLayout.minimumLineSpacing = oldLayout.minimumLineSpacing
            strechyLayout.minimumInteritemSpacing = oldLayout.minimumInteritemSpacing
            strechyLayout.itemSize = oldLayout.itemSize
            strechyLayout.estimatedItemSize = oldLayout.estimatedItemSize
            strechyLayout.scrollDirection = oldLayout.scrollDirection
            strechyLayout.headerReferenceSize = oldLayout.headerReferenceSize
            strechyLayout.footerReferenceSize = oldLayout.footerReferenceSize
            strechyLayout.sectionInset = oldLayout.sectionInset
            self.collectionView?.collectionViewLayout = strechyLayout
        })
        
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func loadContent() {
        self.title = self.summoner.name
        loadRanked()
        loadSummonerStats()
        loadChampionMastery()
        loadRecentGames()
        loadMasteries()
        loadRunes()
    }
    
    func loadRanked() {
        LeagueEndpoint().getLeagueEntryBySummonerIds([self.summoner.summonerId], completion: { (summonerMap) in
            autoreleasepool(invoking: { ()
                // Ranked
                let currentSummoner = summonerMap.values.first
                
                var highestTier: Int = 7
                var highestTierSpelledOut: String = ""
                var highestDivision: Int = 6
                var highestDivisionRoman: String = ""
                
                for league in currentSummoner! {
                    autoreleasepool(invoking: { ()
                        if league.queue == "RANKED_SOLO_5x5" {
                            let entry = league.entries.first
                            
                            if entry?.miniSeries != nil {
                                let progressWithHyphen = entry?.miniSeries?.progress.replacingOccurrences(of: "W", with: "✓ -").replacingOccurrences(of: "L", with: "X -").replacingOccurrences(of: "N", with: "○ -")
                                let progress = progressWithHyphen?.components(separatedBy: "-")
                                let progressString = NSMutableAttributedString()
                                for substring in progress! {
                                    switch substring {
                                    case "✓ ":
                                        progressString.append(NSAttributedString(string: substring, attributes: [NSForegroundColorAttributeName: UIColor.green]))
                                    case "X ":
                                        progressString.append(NSAttributedString(string: substring, attributes: [NSForegroundColorAttributeName: UIColor.red]))
                                    case "○ ":
                                        progressString.append(NSAttributedString(string: substring, attributes: [NSForegroundColorAttributeName: UIColor.white]))
                                    default:
                                        break
                                    }
                                }
                                self.profileHeader.promotionGames?.attributedText = progressString
                            }
                            
                            let lp = self.profileHeader.summonerStats[2] as! NSMutableDictionary
                            lp.setObject(String(entry!.leaguePoints), forKey: "statValue" as NSCopying)
                            self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 2, section: 0)])
                        }
                        
                        if highestTier > LeagueEndpoint().tierToNumber(league.tier) {
                            highestTier = LeagueEndpoint().tierToNumber(league.tier)
                            highestTierSpelledOut = league.tier
                            highestDivision = 6
                            
                            for entry in league.entries {
                                if highestDivision > LeagueEndpoint().romanNumeralToNumber(entry.division) {
                                    highestDivision = LeagueEndpoint().romanNumeralToNumber(entry.division)
                                    highestDivisionRoman = entry.division
                                }
                            }
                        } else if highestTier == LeagueEndpoint().tierToNumber(league.tier) {
                            for entry in league.entries {
                                if highestDivision > LeagueEndpoint().romanNumeralToNumber(entry.division) {
                                    highestDivision = LeagueEndpoint().romanNumeralToNumber(entry.division)
                                    highestDivisionRoman = entry.division
                                }
                            }
                        }
                        
                        if highestTier < 2 {
                            // Challenger & Master
                            // Dont use division
                            self.profileHeader.summonerLevelRankIcon?.image = UIImage(named: highestTierSpelledOut.lowercased())
                            
                            self.profileHeader.summonerLevelRank?.text = highestTierSpelledOut.capitalized
                        } else {
                            // Diamond and lower
                            // Use division
                            self.profileHeader.summonerLevelRankIcon?.image = UIImage(named: highestTierSpelledOut.lowercased() + "_" + highestDivisionRoman.lowercased())
                            
                            self.profileHeader.summonerLevelRank?.text = highestTierSpelledOut.capitalized + " " + highestDivisionRoman.uppercased()
                        }
                    })
                }
            })
        }, notFound: {
            // Unranked
            self.profileHeader.summonerLevelRankIcon?.image = UIImage(named: "provisional")
            
            self.profileHeader.summonerLevelRank?.text = "Level " + String(self.summoner.summonerLevel)
        }) {
            // Error
        }
    }
    
    func loadSummonerStats() {
        StatsEndpoint().getStatsSummaryBySummonerId(self.summoner.summonerId, completion: { (summaryList) in
            for summary in summaryList.playerStatSummaries {
                if summary.playerStatSummaryType == "RankedSolo5x5" {
                    let rWins = self.profileHeader.summonerStats[0] as! NSMutableDictionary
                    rWins.setObject(String(summary.wins), forKey: "statValue" as NSCopying)
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 0, section: 0)])
                    let rLosses = self.profileHeader.summonerStats[1] as! NSMutableDictionary
                    rLosses.setObject(String(summary.losses), forKey: "statValue" as NSCopying)
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 1, section: 0)])
                } else if summary.playerStatSummaryType == "Unranked" {
                    if summary.aggregatedStats.totalChampionKills != nil {
                        let nKills = self.profileHeader.summonerStats[3] as! NSMutableDictionary
                        nKills.setObject(String(summary.aggregatedStats.totalChampionKills!), forKey: "statValue" as NSCopying)
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 3, section: 0)])
                    }
                    if summary.aggregatedStats.totalMinionKills != nil && summary.aggregatedStats.totalNeutralMinionsKilled != nil {
                        let nCS = self.profileHeader.summonerStats[4] as! NSMutableDictionary
                        nCS.setObject(String(summary.aggregatedStats.totalMinionKills! + summary.aggregatedStats.totalNeutralMinionsKilled!), forKey: "statValue" as NSCopying)
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 4, section: 0)])
                    }
                    let nWins = self.profileHeader.summonerStats[5] as! NSMutableDictionary
                    nWins.setObject(String(summary.wins), forKey: "statValue" as NSCopying)
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 5, section: 0)])
                } else if summary.playerStatSummaryType == "AramUnranked5x5" {
                    if summary.aggregatedStats.totalChampionKills != nil {
                        let aKills = self.profileHeader.summonerStats[6] as! NSMutableDictionary
                        aKills.setObject(String(summary.aggregatedStats.totalChampionKills!), forKey: "statValue" as NSCopying)
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 6, section: 0)])
                    }
                    if summary.aggregatedStats.totalTurretsKilled != nil {
                        let aTurrets = self.profileHeader.summonerStats[7] as! NSMutableDictionary
                        aTurrets.setObject(String(summary.aggregatedStats.totalTurretsKilled!), forKey: "statValue" as NSCopying)
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 7, section: 0)])
                    }
                    let aWins = self.profileHeader.summonerStats[8] as! NSMutableDictionary
                    aWins.setObject(String(summary.wins), forKey: "statValue" as NSCopying)
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 8, section: 0)])
                }
            }
        }) { 
            // Error
        }
    }
    
    func loadChampionMastery() {
        ChampionMasteryEndpoint().getAllChampsBySummonerId(self.summoner.summonerId, completion: { (champions) in
            if champions.count > 0 {
                self.cm_top3champs.append(champions[0])
            }
            if champions.count > 1 {
                self.cm_top3champs.append(champions[1])
            }
            if champions.count > 2 {
                self.cm_top3champs.append(champions[2])
            }
            for tile in PlistManager().loadProfileViewTileOrder() as! [[String: String]] {
                if tile["tileType"]! as String == "champMastery" {
                    self.collectionView?.reloadItems(at: [IndexPath(item: PlistManager().loadProfileViewTileOrder().index(of: tile), section: 0)])
                }
            }
            
            var championMasteryScore = 0
            for champion in champions {
                championMasteryScore += champion.championLevel
            }
            self.profileHeader.summonerChampMasteryScore?.text = String(championMasteryScore) + " Mastery Score"
        }, notFound: {
            // ???
        }) { 
            // Error
        }
    }
    
    func loadRecentGames() {
        GameEndpoint().getRecentGamesBySummonerId(self.summoner.summonerId, completion: { (recentGamesMap) in
            self.rc_lastGame = recentGamesMap.games.first!
            self.rc_totalGames = 0
            self.rc_gamesWon = 0
            for game in recentGamesMap.games {
                if !game.invalid {
                    self.rc_totalGames += 1
                    if game.stats.win {
                        self.rc_gamesWon += 1
                    }
                }
            }
            for tile in PlistManager().loadProfileViewTileOrder() as! [[String: String]] {
                if tile["tileType"]! as String == "recentGames" {
                    self.collectionView?.reloadItems(at: [IndexPath(item: PlistManager().loadProfileViewTileOrder().index(of: tile), section: 0)])
                }
            }
        }) { 
            // Error
        }
    }
    
    func loadMasteries() {
        SummonerEndpoint().getMasteriesForSummonerIds([self.summoner.summonerId], completion: { (summonerMap) in
            let currentSummoner = summonerMap.values.first
            
            for page in currentSummoner!.pages {
                if page.current {
                    self.mas_currentPage = page
                    break
                }
            }
            for tile in PlistManager().loadProfileViewTileOrder() as! [[String: String]] {
                if tile["tileType"]! as String == "masteries" {
                    self.collectionView?.reloadItems(at: [IndexPath(item: PlistManager().loadProfileViewTileOrder().index(of: tile), section: 0)])
                }
            }
        }) { 
            // Error
        }
    }
    
    func loadRunes() {
        SummonerEndpoint().getRunesForSummonerIds([self.summoner.summonerId], completion: { (summonerMap) in
            let currentSummoner = summonerMap.values.first
            
            for page in currentSummoner!.pages {
                if page.current {
                    self.run_currentPage = page
                    
                    var count = page.slots.count
                    for slot in page.slots {
                        StaticDataEndpoint().getRuneInfoById(slot.runeId, runeData: .Stats, completion: { (rune) in
                            if rune.stats.FlatArmorMod != 0.0 {
                                if (self.run_currentPage_stats["FlatArmorMod"] != nil) {
                                    self.run_currentPage_stats["FlatArmorMod"]! += rune.stats.FlatArmorMod
                                } else {
                                    self.run_currentPage_stats["FlatArmorMod"] = rune.stats.FlatArmorMod
                                }
                            }
                            if rune.stats.FlatCritChanceMod != 0.0 {
                                if (self.run_currentPage_stats["FlatCritChanceMod"] != nil) {
                                    self.run_currentPage_stats["FlatCritChanceMod"]! += rune.stats.FlatCritChanceMod
                                } else {
                                    self.run_currentPage_stats["FlatCritChanceMod"] = rune.stats.FlatCritChanceMod
                                }
                            }
                            if rune.stats.FlatCritDamageMod != 0.0 {
                                if (self.run_currentPage_stats["FlatCritDamageMod"] != nil) {
                                    self.run_currentPage_stats["FlatCritDamageMod"]! += rune.stats.FlatCritDamageMod
                                } else {
                                    self.run_currentPage_stats["FlatCritDamageMod"] = rune.stats.FlatCritDamageMod
                                }
                            }
                            if rune.stats.FlatEnergyPoolMod != 0.0 {
                                if (self.run_currentPage_stats["FlatEnergyPoolMod"] != nil) {
                                    self.run_currentPage_stats["FlatEnergyPoolMod"]! += rune.stats.FlatEnergyPoolMod
                                } else {
                                    self.run_currentPage_stats["FlatEnergyPoolMod"] = rune.stats.FlatEnergyPoolMod
                                }
                            }
                            if rune.stats.FlatEnergyRegenMod != 0.0 {
                                if (self.run_currentPage_stats["FlatEnergyRegenMod"] != nil) {
                                    self.run_currentPage_stats["FlatEnergyRegenMod"]! += rune.stats.FlatEnergyRegenMod
                                } else {
                                    self.run_currentPage_stats["FlatEnergyRegenMod"] = rune.stats.FlatEnergyRegenMod
                                }
                            }
                            if rune.stats.FlatHPPoolMod != 0.0 {
                                if (self.run_currentPage_stats["FlatHPPoolMod"] != nil) {
                                    self.run_currentPage_stats["FlatHPPoolMod"]! += rune.stats.FlatHPPoolMod
                                } else {
                                    self.run_currentPage_stats["FlatHPPoolMod"] = rune.stats.FlatHPPoolMod
                                }
                            }
                            if rune.stats.FlatHPRegenMod != 0.0 {
                                if (self.run_currentPage_stats["FlatHPRegenMod"] != nil) {
                                    self.run_currentPage_stats["FlatHPRegenMod"]! += rune.stats.FlatHPRegenMod
                                } else {
                                    self.run_currentPage_stats["FlatHPRegenMod"] = rune.stats.FlatHPRegenMod
                                }
                            }
                            if rune.stats.FlatMagicDamageMod != 0.0 {
                                if (self.run_currentPage_stats["FlatMagicDamageMod"] != nil) {
                                    self.run_currentPage_stats["FlatMagicDamageMod"]! += rune.stats.FlatMagicDamageMod
                                } else {
                                    self.run_currentPage_stats["FlatMagicDamageMod"] = rune.stats.FlatMagicDamageMod
                                }
                            }
                            if rune.stats.FlatMPPoolMod != 0.0 {
                                if (self.run_currentPage_stats["FlatMPPoolMod"] != nil) {
                                    self.run_currentPage_stats["FlatMPPoolMod"]! += rune.stats.FlatMPPoolMod
                                } else {
                                    self.run_currentPage_stats["FlatMPPoolMod"] = rune.stats.FlatMPPoolMod
                                }
                            }
                            if rune.stats.FlatMPRegenMod != 0.0 {
                                if (self.run_currentPage_stats["FlatMPRegenMod"] != nil) {
                                    self.run_currentPage_stats["FlatMPRegenMod"]! += rune.stats.FlatMPRegenMod
                                } else {
                                    self.run_currentPage_stats["FlatMPRegenMod"] = rune.stats.FlatMPRegenMod
                                }
                            }
                            if rune.stats.FlatPhysicalDamageMod != 0.0 {
                                if (self.run_currentPage_stats["FlatPhysicalDamageMod"] != nil) {
                                    self.run_currentPage_stats["FlatPhysicalDamageMod"]! += rune.stats.FlatPhysicalDamageMod
                                } else {
                                    self.run_currentPage_stats["FlatPhysicalDamageMod"] = rune.stats.FlatPhysicalDamageMod
                                }
                            }
                            if rune.stats.FlatSpellBlockMod != 0.0 {
                                if (self.run_currentPage_stats["FlatSpellBlockMod"] != nil) {
                                    self.run_currentPage_stats["FlatSpellBlockMod"]! += rune.stats.FlatSpellBlockMod
                                } else {
                                    self.run_currentPage_stats["FlatSpellBlockMod"] = rune.stats.FlatSpellBlockMod
                                }
                            }
                            if rune.stats.PercentAttackSpeedMod != 0.0 {
                                if (self.run_currentPage_stats["PercentAttackSpeedMod"] != nil) {
                                    self.run_currentPage_stats["PercentAttackSpeedMod"]! += rune.stats.PercentAttackSpeedMod
                                } else {
                                    self.run_currentPage_stats["PercentAttackSpeedMod"] = rune.stats.PercentAttackSpeedMod
                                }
                            }
                            if rune.stats.PercentEXPBonus != 0.0 {
                                if (self.run_currentPage_stats["PercentEXPBonus"] != nil) {
                                    self.run_currentPage_stats["PercentEXPBonus"]! += rune.stats.PercentEXPBonus
                                } else {
                                    self.run_currentPage_stats["PercentEXPBonus"] = rune.stats.PercentEXPBonus
                                }
                            }
                            if rune.stats.PercentHPPoolMod != 0.0 {
                                if (self.run_currentPage_stats["PercentHPPoolMod"] != nil) {
                                    self.run_currentPage_stats["PercentHPPoolMod"]! += rune.stats.PercentHPPoolMod
                                } else {
                                    self.run_currentPage_stats["PercentHPPoolMod"] = rune.stats.PercentHPPoolMod
                                }
                            }
                            if rune.stats.PercentLifeStealMod != 0.0 {
                                if (self.run_currentPage_stats["PercentLifeStealMod"] != nil) {
                                    self.run_currentPage_stats["PercentLifeStealMod"]! += rune.stats.PercentLifeStealMod
                                } else {
                                    self.run_currentPage_stats["PercentLifeStealMod"] = rune.stats.PercentLifeStealMod
                                }
                            }
                            if rune.stats.PercentMovementSpeedMod != 0.0 {
                                if (self.run_currentPage_stats["PercentMovementSpeedMod"] != nil) {
                                    self.run_currentPage_stats["PercentMovementSpeedMod"]! += rune.stats.PercentMovementSpeedMod
                                } else {
                                    self.run_currentPage_stats["PercentMovementSpeedMod"] = rune.stats.PercentMovementSpeedMod
                                }
                            }
                            if rune.stats.PercentSpellVampMod != 0.0 {
                                if (self.run_currentPage_stats["PercentSpellVampMod"] != nil) {
                                    self.run_currentPage_stats["PercentSpellVampMod"]! += rune.stats.PercentSpellVampMod
                                } else {
                                    self.run_currentPage_stats["PercentSpellVampMod"] = rune.stats.PercentSpellVampMod
                                }
                            }
                            if rune.stats.rFlatArmorModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatArmorModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatArmorModPerLevel"]! += rune.stats.rFlatArmorModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatArmorModPerLevel"] = rune.stats.rFlatArmorModPerLevel
                                }
                            }
                            if rune.stats.rFlatArmorPenetrationMod != 0.0 {
                                if (self.run_currentPage_stats["rFlatArmorPenetrationMod"] != nil) {
                                    self.run_currentPage_stats["rFlatArmorPenetrationMod"]! += rune.stats.rFlatArmorPenetrationMod
                                } else {
                                    self.run_currentPage_stats["rFlatArmorPenetrationMod"] = rune.stats.rFlatArmorPenetrationMod
                                }
                            }
                            if rune.stats.rFlatEnergyModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatEnergyModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatEnergyModPerLevel"]! += rune.stats.rFlatEnergyModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatEnergyModPerLevel"] = rune.stats.rFlatEnergyModPerLevel
                                }
                            }
                            if rune.stats.rFlatEnergyRegenModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatEnergyRegenModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatEnergyRegenModPerLevel"]! += rune.stats.rFlatEnergyRegenModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatEnergyRegenModPerLevel"] = rune.stats.rFlatEnergyRegenModPerLevel
                                }
                            }
                            if rune.stats.rFlatGoldPer10Mod != 0.0 {
                                if (self.run_currentPage_stats["rFlatGoldPer10Mod"] != nil) {
                                    self.run_currentPage_stats["rFlatGoldPer10Mod"]! += rune.stats.rFlatGoldPer10Mod
                                } else {
                                    self.run_currentPage_stats["rFlatGoldPer10Mod"] = rune.stats.rFlatGoldPer10Mod
                                }
                            }
                            if rune.stats.rFlatHPModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatHPModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatHPModPerLevel"]! += rune.stats.rFlatHPModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatHPModPerLevel"] = rune.stats.rFlatHPModPerLevel
                                }
                            }
                            if rune.stats.rFlatHPRegenModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatHPRegenModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatHPRegenModPerLevel"]! += rune.stats.rFlatHPRegenModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatHPRegenModPerLevel"] = rune.stats.rFlatHPRegenModPerLevel
                                }
                            }
                            if rune.stats.rFlatMagicDamageModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatMagicDamageModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatMagicDamageModPerLevel"]! += rune.stats.rFlatMagicDamageModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatMagicDamageModPerLevel"] = rune.stats.rFlatMagicDamageModPerLevel
                                }
                            }
                            if rune.stats.rFlatMagicPenetrationMod != 0.0 {
                                if (self.run_currentPage_stats["rFlatMagicPenetrationMod"] != nil) {
                                    self.run_currentPage_stats["rFlatMagicPenetrationMod"]! += rune.stats.rFlatMagicPenetrationMod
                                } else {
                                    self.run_currentPage_stats["rFlatMagicPenetrationMod"] = rune.stats.rFlatMagicPenetrationMod
                                }
                            }
                            if rune.stats.rFlatMPModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatMPModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatMPModPerLevel"]! += rune.stats.rFlatMPModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatMPModPerLevel"] = rune.stats.rFlatMPModPerLevel
                                }
                            }
                            if rune.stats.rFlatMPRegenModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatMPRegenModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatMPRegenModPerLevel"]! += rune.stats.rFlatMPRegenModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatMPRegenModPerLevel"] = rune.stats.rFlatMPRegenModPerLevel
                                }
                            }
                            if rune.stats.rFlatPhysicalDamageModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatPhysicalDamageModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatPhysicalDamageModPerLevel"]! += rune.stats.rFlatPhysicalDamageModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatPhysicalDamageModPerLevel"] = rune.stats.rFlatPhysicalDamageModPerLevel
                                }
                            }
                            if rune.stats.rFlatSpellBlockModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rFlatSpellBlockModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rFlatSpellBlockModPerLevel"]! += rune.stats.rFlatSpellBlockModPerLevel
                                } else {
                                    self.run_currentPage_stats["rFlatSpellBlockModPerLevel"] = rune.stats.rFlatSpellBlockModPerLevel
                                }
                            }
                            if rune.stats.rPercentCooldownMod != 0.0 {
                                if (self.run_currentPage_stats["rPercentCooldownMod"] != nil) {
                                    self.run_currentPage_stats["rPercentCooldownMod"]! += rune.stats.rPercentCooldownMod
                                } else {
                                    self.run_currentPage_stats["rPercentCooldownMod"] = rune.stats.rPercentCooldownMod
                                }
                            }
                            if rune.stats.rPercentCooldownModPerLevel != 0.0 {
                                if (self.run_currentPage_stats["rPercentCooldownModPerLevel"] != nil) {
                                    self.run_currentPage_stats["rPercentCooldownModPerLevel"]! += rune.stats.rPercentCooldownModPerLevel
                                } else {
                                    self.run_currentPage_stats["rPercentCooldownModPerLevel"] = rune.stats.rPercentCooldownModPerLevel
                                }
                            }
                            if rune.stats.rPercentTimeDeadMod != 0.0 {
                                if (self.run_currentPage_stats["rPercentTimeDeadMod"] != nil) {
                                    self.run_currentPage_stats["rPercentTimeDeadMod"]! += rune.stats.rPercentTimeDeadMod
                                } else {
                                    self.run_currentPage_stats["rPercentTimeDeadMod"] = rune.stats.rPercentTimeDeadMod
                                }
                            }
                            
                            count -= 1
                            if count == 0 {
                                for tile in PlistManager().loadProfileViewTileOrder() as! [[String: String]] {
                                    if tile["tileType"]! as String == "runes" {
                                        self.collectionView?.reloadItems(at: [IndexPath(item: PlistManager().loadProfileViewTileOrder().index(of: tile), section: 0)])
                                    }
                                }
                            }
                        }, notFound: {
                            // ???
                            count -= 1
                            if count == 0 {
                                for tile in PlistManager().loadProfileViewTileOrder() as! [[String: String]] {
                                    if tile["tileType"]! as String == "runes" {
                                        self.collectionView?.reloadItems(at: [IndexPath(item: PlistManager().loadProfileViewTileOrder().index(of: tile), section: 0)])
                                    }
                                }
                            }
                        }, errorBlock: {
                            // Error
                            count -= 1
                            if count == 0 {
                                for tile in PlistManager().loadProfileViewTileOrder() as! [[String: String]] {
                                    if tile["tileType"]! as String == "runes" {
                                        self.collectionView?.reloadItems(at: [IndexPath(item: PlistManager().loadProfileViewTileOrder().index(of: tile), section: 0)])
                                    }
                                }
                            }
                        })
                    }
                    
                    break
                }
            }
        }) { 
            // Error
        }
    }
    
    // MARK: - Header delegate
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addSummonerToRecents() {
        PlistManager().addToRecentSummoners(self.summoner)
    }
    
    internal func showParticiapantProfileInfo(_ summoner: SummonerDto) {
        self.delegate?.showParticiapantProfileInfo(summoner)
        self.goBack()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        autoreleasepool { ()
            if segue.identifier == "showCurrentGame" {
                let destinationNav = segue.destination as! UINavigationController
                let destination = destinationNav.topViewController as! Profile_CurrentGame
                destination.summoner = self.summoner
            } else if segue.identifier == "showChampionMasteriesDetail" {
                let destinationNav = segue.destination as! UINavigationController
                let destination = destinationNav.topViewController as! Profile_ChampionMastery
                destination.summoner = self.summoner
            } else if segue.identifier == "showRecentGamesDetail" {
                let destinationNav = segue.destination as! UINavigationController
                let destination = destinationNav.topViewController as! Profile_RecentGames
                destination.summoner = self.summoner
            } else if segue.identifier == "showMasteriesDetail" {
                let destinationNav = segue.destination as! UINavigationController
                let destination = destinationNav.topViewController as! Profile_Masteries
                destination.summoner = self.summoner
            } else if segue.identifier == "showRunesDetail" {
                let destinationNav = segue.destination as! UINavigationController
                let destination = destinationNav.topViewController as! Profile_Runes
                destination.summoner = self.summoner
            }
        }
    }
    
    // MARK: - Collection view data source
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return PlistManager().loadProfileViewTileOrder().count
        } else {
            return run_currentPage_stats.values.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let niceTileOrder = PlistManager().loadProfileViewTileOrder() as! [[String: String]]
            switch niceTileOrder[indexPath.row]["tileType"] {
            case "champMastery" as NSString:
                // Champion Mastery
                let champMasteryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_champ_mastery", for: indexPath) as! ProfileView_ChampMastery
                
                champMasteryCell.setupCell()
                
                if self.cm_top3champs.count > 0 {
                    let championMastery = self.cm_top3champs[0]
                    
                    StaticDataEndpoint().getChampionInfoById(championMastery.championId, championData: .Image, completion: { (champion) in
                        autoreleasepool(invoking: { ()
                            DDragon().getChampionLoadingArt(champion.image!.full, skinNumber: 0, completion: { (champLoadingArtUrl) in
                                champMasteryCell.champ1bg?.setImageWith(champLoadingArtUrl)
                            })
                            // Use the new LCU icon if exists
                            if let champIcon = DDragon().getLcuChampionSquareArt(championMastery.championId) {
                                champMasteryCell.champ1squareIcon?.image = champIcon
                            } else {
                                DDragon().getChampionSquareArt(champion.image!.full, completion: { (champSquareArtUrl) in
                                    champMasteryCell.champ1squareIcon?.setImageWith(champSquareArtUrl)
                                })
                            }
                            champMasteryCell.champ1name?.text = champion.name
                        })
                    }, notFound: {
                        // 404
                    }, errorBlock: {
                        // Error
                    })
                    
                    champMasteryCell.champ1progressBar?.value = CGFloat(championMastery.championPointsSinceLastLevel)
                    champMasteryCell.champ1progressBar?.maxValue = CGFloat(championMastery.championPointsSinceLastLevel + championMastery.championPointsUntilNextLevel)
                    
                    champMasteryCell.champ1masteryIcon?.image = UIImage(named: "rank" + String(championMastery.championLevel))
                    
                    if championMastery.championPointsUntilNextLevel > 0 {
                        champMasteryCell.champ1masteryScore?.text = String(championMastery.championPoints) + " / " + String(championMastery.championPoints + championMastery.championPointsUntilNextLevel)
                    } else {
                        champMasteryCell.champ1masteryScore?.text = String(championMastery.championPoints)
                    }
                }
                
                if self.cm_top3champs.count > 1 {
                    let championMastery = self.cm_top3champs[1]
                    
                    StaticDataEndpoint().getChampionInfoById(championMastery.championId, championData: .Image, completion: { (champion) in
                        DDragon().getChampionLoadingArt(champion.image!.full, skinNumber: 0, completion: { (champLoadingArtUrl) in
                            champMasteryCell.champ2bg?.setImageWith(champLoadingArtUrl)
                        })
                        // Use the new LCU icon if exists
                        if let champIcon = DDragon().getLcuChampionSquareArt(championMastery.championId) {
                            champMasteryCell.champ2squareIcon?.image = champIcon
                        } else {
                            DDragon().getChampionSquareArt(champion.image!.full, completion: { (champSquareArtUrl) in
                                champMasteryCell.champ2squareIcon?.setImageWith(champSquareArtUrl)
                            })
                        }
                        champMasteryCell.champ2name?.text = champion.name
                    }, notFound: {
                        // 404
                    }, errorBlock: {
                        // Error
                    })
                    
                    champMasteryCell.champ2progressBar?.value = CGFloat(championMastery.championPointsSinceLastLevel)
                    champMasteryCell.champ2progressBar?.maxValue = CGFloat(championMastery.championPointsSinceLastLevel + championMastery.championPointsUntilNextLevel)
                    
                    champMasteryCell.champ2masteryIcon?.image = UIImage(named: "rank" + String(championMastery.championLevel))
                    
                    if championMastery.championPointsUntilNextLevel > 0 {
                        champMasteryCell.champ2masteryScore?.text = String(championMastery.championPoints) + " / " + String(championMastery.championPoints + championMastery.championPointsUntilNextLevel)
                    } else {
                        champMasteryCell.champ2masteryScore?.text = String(championMastery.championPoints)
                    }
                }
                
                if self.cm_top3champs.count > 2 {
                    let championMastery = self.cm_top3champs[2]
                    
                    StaticDataEndpoint().getChampionInfoById(championMastery.championId, championData: .Image, completion: { (champion) in
                        DDragon().getChampionLoadingArt(champion.image!.full, skinNumber: 0, completion: { (champLoadingArtUrl) in
                            champMasteryCell.champ3bg?.setImageWith(champLoadingArtUrl)
                        })
                        // Use the new LCU icon if exists
                        if let champIcon = DDragon().getLcuChampionSquareArt(championMastery.championId) {
                            champMasteryCell.champ3squareIcon?.image = champIcon
                        } else {
                            DDragon().getChampionSquareArt(champion.image!.full, completion: { (champSquareArtUrl) in
                                champMasteryCell.champ3squareIcon?.setImageWith(champSquareArtUrl)
                            })
                        }
                        champMasteryCell.champ3name?.text = champion.name
                    }, notFound: {
                        // 404
                    }, errorBlock: {
                        // Error
                    })
                    
                    champMasteryCell.champ3progressBar?.value = CGFloat(championMastery.championPointsSinceLastLevel)
                    champMasteryCell.champ3progressBar?.maxValue = CGFloat(championMastery.championPointsSinceLastLevel + championMastery.championPointsUntilNextLevel)
                    
                    champMasteryCell.champ3masteryIcon?.image = UIImage(named: "rank" + String(championMastery.championLevel))
                    
                    if championMastery.championPointsUntilNextLevel > 0 {
                        champMasteryCell.champ3masteryScore?.text = String(championMastery.championPoints) + " / " + String(championMastery.championPoints + championMastery.championPointsUntilNextLevel)
                    } else {
                        champMasteryCell.champ3masteryScore?.text = String(championMastery.championPoints)
                    }
                }
                
                return champMasteryCell
            case "recentGames" as NSString:
                // Recent Games
                let recentGamesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_recent_games", for: indexPath) as! ProfileView_RecentGames
                
                recentGamesCell.setupCell()
                
                var percentage = 0
                if self.rc_totalGames > 0 {
                    percentage = self.rc_gamesWon * 100 / self.rc_totalGames
                }
                recentGamesCell.winratePercentage?.text = String(percentage) + "%"
                if percentage >= 0 && percentage <= 50 {
                    recentGamesCell.winratePercentage?.textColor = UIColor(colorLiteralRed: Float(1), green: Float(percentage * 2) / 100, blue: Float(0), alpha: Float(1))
                } else {
                    recentGamesCell.winratePercentage?.textColor = UIColor(colorLiteralRed: Float(1) - Float(percentage - 50) / 100, green: Float(1), blue: Float(0), alpha: Float(1))
                }
                recentGamesCell.totalGamesCounted?.text = "winrate\nlast " + String(self.rc_totalGames) + " games"
                
                if self.rc_lastGame.mapId == 10 {
                    recentGamesCell.lastGameMap?.image = UIImage(named: "shadowIsles")
                } else if self.rc_lastGame.mapId == 1 || self.rc_lastGame.mapId == 11 {
                    recentGamesCell.lastGameMap?.image = UIImage(named: "summonersRift")
                } else if self.rc_lastGame.mapId == 12 {
                    recentGamesCell.lastGameMap?.image = UIImage(named: "howlingAbyss")
                }
                
                if self.rc_lastGame.championId != 0 {
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(self.rc_lastGame.championId) {
                        recentGamesCell.lastGameChamp?.image = champIcon
                    } else {
                        StaticDataEndpoint().getChampionInfoById(self.rc_lastGame.championId, championData: .Image, completion: { (champion) in
                            DDragon().getChampionSquareArt(champion.image!.full, completion: { (champSquareArtUrl) in
                                recentGamesCell.lastGameChamp?.setImageWith(champSquareArtUrl)
                            })
                        }, notFound: {
                            // 404
                        }, errorBlock: {
                            // Error
                        })
                    }
                }
                
                var kills = 0
                if self.rc_lastGame.stats.championsKilled != nil {
                    kills = self.rc_lastGame.stats.championsKilled!
                }
                var deaths = 0
                if self.rc_lastGame.stats.numDeaths != nil {
                    deaths = self.rc_lastGame.stats.numDeaths!
                }
                var assists = 0
                if self.rc_lastGame.stats.assists != nil {
                    assists = self.rc_lastGame.stats.assists!
                }
                var won = ""
                if self.rc_lastGame.stats.win {
                    won = " WIN"
                } else {
                    won = " LOSS"
                }
                
                recentGamesCell.lastGameScore?.text = String(kills) + "/" + String(deaths) + "/" + String(assists) + won
                
                return recentGamesCell
            case "masteries" as NSString:
                // Masteries
                let masteriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_masteries", for: indexPath) as! ProfileView_Masteries
                
                masteriesCell.setupCell()
                
                masteriesCell.masteryPageName?.text = self.mas_currentPage.name
                var leftColumnCount = 0
                for mastery in self.mas_currentPage.masteries {
                    if mastery.masteryId > 6100 && mastery.masteryId < 6200 {
                        leftColumnCount += mastery.rank
                        if mastery.masteryId == 6161 || mastery.masteryId == 6162 || mastery.masteryId == 6164 {
                            // Keystone
                            DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                                masteriesCell.leftColumnKeystone?.setImageWith(URLRequest(url: masteryIconUrl), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                                    masteriesCell.leftColumnKeystone?.image = image
                                    masteriesCell.leftColumnKeystone?.isHidden = false
                                }, failure: { (request, response, error) in
                                    masteriesCell.leftColumnKeystone?.image = UIImage(named: "poroIcon")
                                    masteriesCell.leftColumnKeystone?.isHidden = false
                                })
                            })
                        }
                    }
                }
                masteriesCell.leftColumnValue?.text = String(leftColumnCount)
                
                var middleColumnCount = 0
                for mastery in self.mas_currentPage.masteries {
                    if mastery.masteryId > 6300 && mastery.masteryId < 6400 {
                        middleColumnCount += mastery.rank
                        if mastery.masteryId == 6361 || mastery.masteryId == 6362 || mastery.masteryId == 6363 {
                            // Keystone
                            DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                                masteriesCell.middleColumnKeystone?.setImageWith(URLRequest(url: masteryIconUrl), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                                    masteriesCell.middleColumnKeystone?.image = image
                                    masteriesCell.middleColumnKeystone?.isHidden = false
                                }, failure: { (request, response, error) in
                                    masteriesCell.middleColumnKeystone?.image = UIImage(named: "poroIcon")
                                    masteriesCell.middleColumnKeystone?.isHidden = false
                                })
                            })
                        }
                    }
                }
                masteriesCell.middleColumnValue?.text = String(middleColumnCount)
                
                var rightColumnCount = 0
                for mastery in self.mas_currentPage.masteries {
                    if mastery.masteryId > 6200 && mastery.masteryId < 6300 {
                        rightColumnCount += mastery.rank
                        if mastery.masteryId == 6261 || mastery.masteryId == 6262 || mastery.masteryId == 6263 {
                            // Keystone
                            DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                                masteriesCell.rightColumnKeystone?.setImageWith(URLRequest(url: masteryIconUrl), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                                    masteriesCell.rightColumnKeystone?.image = image
                                    masteriesCell.rightColumnKeystone?.isHidden = false
                                }, failure: { (request, response, error) in
                                    masteriesCell.rightColumnKeystone?.image = UIImage(named: "poroIcon")
                                    masteriesCell.rightColumnKeystone?.isHidden = false
                                })
                            })
                        }
                    }
                }
                masteriesCell.rightColumnValue?.text = String(rightColumnCount)
                
                return masteriesCell
            case "runes" as NSString:
                // Runes
                let runesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_runes", for: indexPath) as! ProfileView_Runes
                
                runesCell.setupCell()
                
                runesCell.runePageName?.text = self.run_currentPage.name
                
                return runesCell
            default:
                return collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
            }
        } else {
            // Rune Page stat cell
            let runeStatCell = collectionView.dequeueReusableCell(withReuseIdentifier: "runeStatCell", for: indexPath) as! ProfileView_Rune_StatsCell
            
            runeStatCell.runeIcon?.image = UIImage(named: Array(self.run_currentPage_stats.keys)[indexPath.row])
            if Array(self.run_currentPage_stats.values)[indexPath.row] >= 0.0 {
                runeStatCell.runeStat?.text = "+" + String(format: "%.2f", Array(self.run_currentPage_stats.values)[indexPath.row])
            } else {
                runeStatCell.runeStat?.text = String(format: "%.2f", Array(self.run_currentPage_stats.values)[indexPath.row])
            }
            
            return runeStatCell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                self.profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "profile_view_header", for: indexPath) as! ProfileView_Header
                
                self.profileHeader.delegate = self
                self.profileHeader.initialLoad(self.summoner)
                
                return self.profileHeader
            case UICollectionElementKindSectionFooter:
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
            default:
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if collectionView == self.collectionView {
            return true
        } else {
            return false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let newTileOrder = NSMutableArray(array: PlistManager().loadProfileViewTileOrder())
        newTileOrder.removeObject(at: sourceIndexPath.row)
        newTileOrder.insert(PlistManager().loadProfileViewTileOrder()[sourceIndexPath.row], at: destinationIndexPath.row)
        PlistManager().writeProfileViewTileOrder(NSArray(array: newTileOrder))
    }
}
