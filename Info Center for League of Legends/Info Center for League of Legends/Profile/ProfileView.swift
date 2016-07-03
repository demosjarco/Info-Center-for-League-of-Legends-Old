//
//  ProfileView.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ProfileView: MainCollectionViewController, HeaderDelegate {
    var summoner = SummonerDto()
    var tileOrder = NSArray()
    
    var profileHeader = ProfileView_Header()
    var champMasteryCell = ProfileView_ChampMastery()
    
    var recentGamesCell = ProfileView_RecentGames()
    
    var masteriesCell = ProfileView_Masteries()
    
    var runesCell = ProfileView_Runes()
    
    var teamsCell = ProfileView_Teams()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SUMMONER ID: " + String(self.summoner.summonerId))
        
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
                    
                    self.profileHeader.summonerLevelRank?.text = highestTierSpelledOut.capitalized + highestDivisionRoman.uppercased()
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
    
    // MARK: - Header delegate
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addSummonerToRecents() {
        
    }
    
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
                self.champMasteryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_champ_mastery", for: indexPath) as! ProfileView_ChampMastery
                
                
                
                return self.champMasteryCell
            case "recentGames" as NSString:
                // Recent Games
                self.recentGamesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_recent_games", for: indexPath) as! ProfileView_RecentGames
                
                
                
                return self.recentGamesCell
            case "masteries" as NSString:
                // Masteries
                self.masteriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_masteries", for: indexPath) as! ProfileView_Masteries
                
                
                
                return self.masteriesCell
            case "runes" as NSString:
                // Runes
                self.runesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_runes", for: indexPath) as! ProfileView_Runes
                
                
                
                return self.runesCell
            case "teams" as NSString:
                // Teams
                self.teamsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile_view_teams", for: indexPath) as! ProfileView_Teams
                
                
                
                return self.teamsCell
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
