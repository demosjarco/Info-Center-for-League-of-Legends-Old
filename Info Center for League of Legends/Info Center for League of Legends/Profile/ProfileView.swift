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
    var summonerStats = NSMutableArray()
    
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
        setupSummonerStats()
    }
    
    func setupSummonerStats() {
        self.summonerStats.add(NSMutableDictionary(objects: ["Ranked Wins", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Ranked Losses", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["League Points", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal Takedowns", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal CS", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal Wins", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Kills", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Towers Destroyed", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Wins", "--"], forKeys: ["statTitle", "statValue"]))
    }
    
    // MARK: - Header delegate
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addSummonerToRecents() {
        
    }
    
    func getSummonerStats() -> NSMutableArray {
        return self.summonerStats
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
