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
    
    // Recent Games
    var rc_totalGames = 0
    var rc_gamesWon = 0
    var rc_lastGame = GameDto()
    
    // Masteries
    var mas_currentPage = MasteryPageDto()
    
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
        loadMasteries()
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
        GameEndpoint().getRecentGamesBySummonerId(summonerId: self.summoner.summonerId, completion: { (recentGamesMap) in
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
            for tile in self.tileOrder {
                if tile["tileType"] as! String == "recentGames" {
                    self.collectionView?.reloadItems(at: [IndexPath(item: self.tileOrder.index(of: tile), section: 0)])
                }
            }
        }) { 
            // Error
        }
    }
    
    func loadMasteries() {
        SummonerEndpoint().getMasteriesForSummonerIds(summonerIds: [self.summoner.summonerId], completion: { (summonerMap) in
            autoreleasepool({ ()
                let currentSummoner = summonerMap.values.first
                
                for page in currentSummoner!.pages {
                    if page.current {
                        self.mas_currentPage = page
                        break
                    }
                }
            })
            for tile in self.tileOrder {
                if tile["tileType"] as! String == "masteries" {
                    self.collectionView?.reloadItems(at: [IndexPath(item: self.tileOrder.index(of: tile), section: 0)])
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
                
                autoreleasepool({ ()
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
                })
                recentGamesCell.totalGamesCounted?.text = "winrate\nlast " + String(self.rc_totalGames) + " games"
                
                if self.rc_lastGame.mapId == 10 {
                    recentGamesCell.lastGameMap?.image = UIImage(named: "shadowIsles")
                } else if self.rc_lastGame.mapId == 1 || self.rc_lastGame.mapId == 11 {
                    recentGamesCell.lastGameMap?.image = UIImage(named: "summonersRift")
                } else if self.rc_lastGame.mapId == 12 {
                    recentGamesCell.lastGameMap?.image = UIImage(named: "howlingAbyss")
                }
                
                autoreleasepool({ ()
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
                })
                
                return recentGamesCell
            case "masteries" as NSString:
                // Masteries
                let masteriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_masteries", for: indexPath) as! ProfileView_Masteries
                
                masteriesCell.setupCell()
                
                masteriesCell.masteryPageName?.text = self.mas_currentPage.name
                autoreleasepool({ ()
                    var leftColumnCount = 0
                    for mastery in self.mas_currentPage.masteries {
                        if mastery.masteryId > 6100 && mastery.masteryId < 6200 {
                            leftColumnCount += mastery.rank
                            if mastery.masteryId == 6161 || mastery.masteryId == 6162 || mastery.masteryId == 6164 {
                                // Keystone
                                DDragon().getMasteryIcon(masteryId: mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
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
                })
                
                autoreleasepool({ ()
                    var middleColumnCount = 0
                    for mastery in self.mas_currentPage.masteries {
                        if mastery.masteryId > 6300 && mastery.masteryId < 6400 {
                            middleColumnCount += mastery.rank
                            if mastery.masteryId == 6361 || mastery.masteryId == 6362 || mastery.masteryId == 6363 {
                                // Keystone
                                DDragon().getMasteryIcon(masteryId: mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                                    print(String(masteryIconUrl))
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
                })
                
                autoreleasepool({ ()
                    var rightColumnCount = 0
                    for mastery in self.mas_currentPage.masteries {
                        if mastery.masteryId > 6200 && mastery.masteryId < 6300 {
                            rightColumnCount += mastery.rank
                            if mastery.masteryId == 6261 || mastery.masteryId == 6262 || mastery.masteryId == 6263 {
                                // Keystone
                                DDragon().getMasteryIcon(masteryId: mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
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
                })
                
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
