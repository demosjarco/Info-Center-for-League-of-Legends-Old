//
//  ProfileView.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ProfileView: MainCollectionViewController, HeaderDelegate, RecentGames_SummaryTileDelegate {
    var summoner = SummonerDto()
    var tileOrder = NSArray()
    
    var profileHeader = ProfileView_Header()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tileOrder = PlistManager().loadProfileViewTileOrder()
        
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
        loadRecentGames()
    }
    
    func loadRanked() {
        LeagueEndpoint().getLeagueEntryBySummonerIds(summonerIds: [self.summoner.summonerId], completion: { (summonerMap) in
            // Ranked
            let currentSummoner = summonerMap.values.first
            
            var highestTier: Int = 7
            var highestTierSpelledOut: String = ""
            var highestDivision: Int = 6
            var highestDivisionRoman: String = ""
            
            for league in currentSummoner! {
                if league.queue == "RANKED_SOLO_5x5" {
                    let entry = league.entries.first
                    
                    if entry?.miniSeries != nil {
                        let progressWithHyphen = entry?.miniSeries?.progress.replacingOccurrences(of: "W", with: "✓ -").replacingOccurrences(of: "L", with: "X -").replacingOccurrences(of: "N", with: "○ -")
                        let progress = progressWithHyphen?.components(separatedBy: "-")
                        let progressString = NSMutableAttributedString()
                        for substring in progress! {
                            switch substring {
                            case "✓ ":
                                progressString.append(AttributedString(string: substring, attributes: [NSForegroundColorAttributeName: UIColor.green()]))
                            case "X ":
                                progressString.append(AttributedString(string: substring, attributes: [NSForegroundColorAttributeName: UIColor.red()]))
                            case "○ ":
                                progressString.append(AttributedString(string: substring, attributes: [NSForegroundColorAttributeName: UIColor.white()]))
                            default:
                                break
                            }
                        }
                        self.profileHeader.promotionGames?.attributedText = progressString
                    }
                    
                    autoreleasepool({ ()
                        let lp = self.profileHeader.summonerStats[2] as! NSMutableDictionary
                        lp.setObject(String(entry!.leaguePoints), forKey: "statValue")
                    })
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 2, section: 0)])
                }
                
                if highestTier > LeagueEndpoint().tierToNumber(tier: league.tier) {
                    highestTier = LeagueEndpoint().tierToNumber(tier: league.tier)
                    highestTierSpelledOut = league.tier
                    highestDivision = 6
                    
                    for entry in league.entries {
                        if highestDivision > LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division) {
                            highestDivision = LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division)
                            highestDivisionRoman = entry.division
                        }
                    }
                } else if highestTier == LeagueEndpoint().tierToNumber(tier: league.tier) {
                    for entry in league.entries {
                        if highestDivision > LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division) {
                            highestDivision = LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division)
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
            }
        }, notFound: {
            // Unranked
            self.profileHeader.summonerLevelRankIcon?.image = UIImage(named: "provisional")
            
            self.profileHeader.summonerLevelRank?.text = "Level " + String(self.summoner.summonerLevel)
        }) {
            // Error
        }
    }
    
    func loadSummonerStats() {
        StatsEndpoint().getStatsSummaryBySummonerId(summonerId: self.summoner.summonerId, completion: { (summaryList) in
            for summary in summaryList.playerStatSummaries {
                if summary.playerStatSummaryType == "RankedSolo5x5" {
                    autoreleasepool({ ()
                        let rWins = self.profileHeader.summonerStats[0] as! NSMutableDictionary
                        rWins.setObject(String(summary.wins), forKey: "statValue")
                    })
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 0, section: 0)])
                    autoreleasepool({ ()
                        let rLosses = self.profileHeader.summonerStats[1] as! NSMutableDictionary
                        rLosses.setObject(String(summary.losses), forKey: "statValue")
                    })
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 1, section: 0)])
                } else if summary.playerStatSummaryType == "Unranked" {
                    if summary.aggregatedStats.totalChampionKills != nil {
                        autoreleasepool({ ()
                            let nKills = self.profileHeader.summonerStats[3] as! NSMutableDictionary
                            nKills.setObject(String(summary.aggregatedStats.totalChampionKills!), forKey: "statValue")
                        })
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 3, section: 0)])
                    }
                    if summary.aggregatedStats.totalMinionKills != nil && summary.aggregatedStats.totalNeutralMinionsKilled != nil {
                        autoreleasepool({ ()
                            let nCS = self.profileHeader.summonerStats[4] as! NSMutableDictionary
                            nCS.setObject(String(summary.aggregatedStats.totalMinionKills! + summary.aggregatedStats.totalNeutralMinionsKilled!), forKey: "statValue")
                        })
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 4, section: 0)])
                    }
                    autoreleasepool({ ()
                        let nWins = self.profileHeader.summonerStats[5] as! NSMutableDictionary
                        nWins.setObject(String(summary.wins), forKey: "statValue")
                    })
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 5, section: 0)])
                } else if summary.playerStatSummaryType == "AramUnranked5x5" {
                    if summary.aggregatedStats.totalChampionKills != nil {
                        autoreleasepool({ ()
                            let aKills = self.profileHeader.summonerStats[6] as! NSMutableDictionary
                            aKills.setObject(String(summary.aggregatedStats.totalChampionKills!), forKey: "statValue")
                        })
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 6, section: 0)])
                    }
                    if summary.aggregatedStats.totalTurretsKilled != nil {
                        autoreleasepool({ ()
                            let aTurrets = self.profileHeader.summonerStats[7] as! NSMutableDictionary
                            aTurrets.setObject(String(summary.aggregatedStats.totalTurretsKilled!), forKey: "statValue")
                        })
                        self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 7, section: 0)])
                    }
                    autoreleasepool({ ()
                        let aWins = self.profileHeader.summonerStats[8] as! NSMutableDictionary
                        aWins.setObject(String(summary.wins), forKey: "statValue")
                    })
                    self.profileHeader.statsScroller?.reloadItems(at: [IndexPath(item: 8, section: 0)])
                }
            }
        }) { 
            // Error
        }
    }
    
    func loadRecentGames() {
        
    }
    
    // MARK: - Header delegate
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addSummonerToRecents() {
        PlistManager().addToRecentSummoners(newSummoner: self.summoner)
    }
    
    // MARK: - Recent Games delegate
    
    // MARK: - Collection view data source
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tileOrder.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch tileOrder[indexPath.row]["tileType"] {
            case "champMastery" as NSString:
                // Champion Mastery
                let champMasteryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_champ_mastery", for: indexPath) as! ProfileView_ChampMastery
                
                champMasteryCell.setupCell()
                
                return champMasteryCell
            case "recentGames" as NSString:
                // Recent Games
                let recentGamesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_recent_games", for: indexPath) as! ProfileView_RecentGames
                
                recentGamesCell.setupCell()
                
                return recentGamesCell
            case "masteries" as NSString:
                // Masteries
                let masteriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_masteries", for: indexPath) as! ProfileView_Masteries
                
                masteriesCell.setupCell()
                
                return masteriesCell
            case "runes" as NSString:
                // Runes
                let runesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_runes", for: indexPath) as! ProfileView_Runes
                
                runesCell.setupCell()
                
                return runesCell
            case "teams" as NSString:
                // Teams
                let teamsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_teams", for: indexPath) as! ProfileView_Teams
                
                teamsCell.setupCell()
                
                return teamsCell
            default:
                return collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                self.profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "profile_view_header", for: indexPath) as! ProfileView_Header
                
                self.profileHeader.delegate = self
                self.profileHeader.initialLoad(loadedSummoner: self.summoner)
                
                return self.profileHeader
            case UICollectionElementKindSectionFooter:
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
            default:
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let newTileOrder = NSMutableArray(array: tileOrder)
        newTileOrder.removeObject(at: sourceIndexPath.row)
        newTileOrder.insert(tileOrder[sourceIndexPath.row], at: destinationIndexPath.row)
        PlistManager().writeTileOrder(tileOrder: NSArray(array: newTileOrder))
        
        tileOrder = NSArray(array: newTileOrder)
    }
}
