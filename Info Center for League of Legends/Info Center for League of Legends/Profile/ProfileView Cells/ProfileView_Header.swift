//
//  ProfileView_Header.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import BEMSimpleLineGraph

protocol HeaderDelegate {
    func goBack()
    func addSummonerToRecents()
}

class ProfileView_Header: UICollectionReusableView, BEMSimpleLineGraphDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    var delegate:HeaderDelegate?
    var summoner = SummonerDto()
    var summonerStats = NSMutableArray()
    
    var currentGameRefreshCount = 0
    var champName: String?
    var startDate: Date?
    
    @IBOutlet var cover:UIImageView?
    @IBOutlet var addSummonerButton:UIButton?
    @IBOutlet var inGameBanner:ProfileView_InGame?
    @IBOutlet var inGameBannerButton:UIButton?
    
    @IBOutlet var promotionGames:UILabel?
    @IBOutlet var summonerName:UILabel?
    @IBOutlet var summonerLevelRank:UILabel?
    @IBOutlet var summonerLevelRankIcon:UIImageView?
    @IBOutlet var summonerChampMasteryScore:UILabel?
    
    @IBOutlet var profilePic:UIImageView?
    @IBOutlet var profilePicShadow:UIView?
    @IBOutlet var statsScroller:UICollectionView?
    
    func initialLoad(_ loadedSummoner: SummonerDto) {
        self.summoner = loadedSummoner
        self.summonerName?.text = self.summoner.name
        
        // Enable add summoner to recents if not already there
        if !PlistManager().loadRecentSummoners().contains(self.summoner.summonerId) {
            self.addSummonerButton?.isEnabled = true
        }
        
        self.getCurrentGame()
        self.setupSummonerStats()
        self.downloadProfileIconCover()
    }
    
    func getCurrentGame() {
        CurrentGameEndpoint().getSpectatorGameInfo(self.summoner.summonerId, completion: { (game) in
            self.startDate = game.gameStartTime
            
            // Get champ info
            for participant in game.participants {
                if participant.summonerId == self.summoner.summonerId {
                    // Summoner Spell 1
                    StaticDataEndpoint().getSpellInfoById(Int(participant.spell1Id), spellData: .image, completion: { (spellInfo) in
                        DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                            self.inGameBanner?.spell1icon?.setImageWith(spellIconUrl)
                        })
                    }, notFound: { 
                        // ??
                    }, errorBlock: { 
                        // Error
                    })
                    // Summoner Spell 2
                    StaticDataEndpoint().getSpellInfoById(Int(participant.spell2Id), spellData: .image, completion: { (spellInfo) in
                        DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                            self.inGameBanner?.spell2icon?.setImageWith(spellIconUrl)
                        })
                    }, notFound: { 
                        // ??
                    }, errorBlock: { 
                        // Error
                    })
                    
                    // Short map name
                    var mapName = "??"
                    if game.mapId == 9 {
                        mapName = "CS"
                    } else if game.mapId == 10 {
                        mapName = "TT"
                    }  else if game.mapId == 11 {
                        mapName = "SR"
                    } else if game.mapId == 12 {
                        mapName = "HA"
                    } else if game.mapId == 14 {
                        mapName = "BB"
                    }
                    
                    // Easy to read game type
                    var gameType = "??"
                    if game.gameQueueConfigId == 0 {
                        gameType = "Custom"
                    } else if game.gameQueueConfigId == 8 || game.gameQueueConfigId == 2 {
                        gameType = "Normals Blind"
                    } else if game.gameQueueConfigId == 14 || game.gameQueueConfigId == 400 {
                        gameType = "Normal Draft"
                    } else if game.gameQueueConfigId == 9 || game.gameQueueConfigId == 440 {
                        gameType = "Ranked Flex"
                    } else if game.gameQueueConfigId == 42 {
                        gameType = "Ranked Team"
                    } else if game.gameQueueConfigId == 16 {
                        gameType = "Dominion Blind"
                    } else if game.gameQueueConfigId == 17 {
                        gameType = "Dominion Draft"
                    } else if game.gameQueueConfigId == 25 {
                        gameType = "Dominion Coop"
                    } else if game.gameQueueConfigId == 31 || game.gameQueueConfigId == 32 || game.gameQueueConfigId == 33 || game.gameQueueConfigId == 52 {
                        gameType = "Coop"
                    } else if game.gameQueueConfigId == 65 {
                        gameType = "ARAM"
                    } else if game.gameQueueConfigId == 70 {
                        gameType = "One for All"
                    } else if game.gameQueueConfigId == 72 || game.gameQueueConfigId == 73 {
                        gameType = "Snowdown Showdown"
                    } else if game.gameQueueConfigId == 75 || game.gameQueueConfigId == 98 {
                        gameType = "Hexakill"
                    } else if game.gameQueueConfigId == 76 {
                        gameType = "URF"
                    } else if game.gameQueueConfigId == 78 {
                        gameType = "One For All Coop"
                    } else if game.gameQueueConfigId == 83 {
                        gameType = "URF Bots"
                    } else if game.gameQueueConfigId == 91 || game.gameQueueConfigId == 92 || game.gameQueueConfigId == 93 {
                        gameType = "Doom Bots"
                    } else if game.gameQueueConfigId == 96 {
                        gameType = "Acension"
                    } else if game.gameQueueConfigId == 100 {
                        gameType = "Butchers Bridge"
                    } else if game.gameQueueConfigId == 300 {
                        gameType = "King Poro"
                    } else if game.gameQueueConfigId == 310 {
                        gameType = "Nemesis"
                    } else if game.gameQueueConfigId == 313 {
                        gameType = "Black Market Brawlers"
                    } else if game.gameQueueConfigId == 315 {
                        gameType = "Nexus Siege"
                    } else if game.gameQueueConfigId == 317 {
                        gameType = "Definitely Not Dominion"
                    } else if game.gameQueueConfigId == 318 {
                        gameType = "ARURF"
                    } else if game.gameQueueConfigId == 420 {
                        gameType = "Ranked Solo"
                    }
                    
                    self.inGameBanner?.mapGameType?.text = mapName + " - " + gameType
                    
                    // Get champ icon
                    StaticDataEndpoint().getChampionInfoById(Int(participant.championId), championData: .Image, completion: { (champInfo) in
                        // Use the new LCU icon if exists
                        if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(participant.championId)) {
                            self.inGameBanner?.champIcon?.image = champIcon
                        } else {
                            DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                                self.inGameBanner?.champIcon?.setImageWith(champSquareArtUrl)
                            })
                        }
                        
                        self.champName = champInfo.name
                        self.updateCurrentGameTime(nil)
                    }, notFound: {
                        // ???
                    }, errorBlock: {
                        // Error
                    })
                    break
                }
            }
            // Unhide
            DispatchQueue.main.async { [unowned self] in
                self.inGameBannerButton?.isHidden = false
                self.inGameBannerButton?.isEnabled = true
                self.inGameBanner?.isHidden = false
                self.inGameBanner?.frame = CGRect(x: self.inGameBanner!.frame.origin.x - self.inGameBanner!.frame.size.width, y: self.inGameBanner!.frame.origin.y, width: self.inGameBanner!.frame.size.width, height: self.inGameBanner!.frame.size.height)
                self.inGameBannerButton?.frame = CGRect(x: self.inGameBannerButton!.frame.origin.x - self.inGameBannerButton!.frame.size.width, y: self.inGameBannerButton!.frame.origin.y, width: self.inGameBannerButton!.frame.size.width, height: self.inGameBannerButton!.frame.size.height)
                // Animate slide in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    self.inGameBanner?.frame = CGRect(x: self.inGameBanner!.frame.origin.x + self.inGameBanner!.frame.size.width, y: self.inGameBanner!.frame.origin.y, width: self.inGameBanner!.frame.size.width, height: self.inGameBanner!.frame.size.height)
                    self.inGameBannerButton?.frame = CGRect(x: self.inGameBannerButton!.frame.origin.x + self.inGameBannerButton!.frame.size.width, y: self.inGameBannerButton!.frame.origin.y, width: self.inGameBannerButton!.frame.size.width, height: self.inGameBannerButton!.frame.size.height)
                }, completion: nil)
            }
        }, notFound: { 
            // Stay hidden
            DispatchQueue.main.async { [unowned self] in
                self.inGameBannerButton?.isHidden = true
                self.inGameBannerButton?.isEnabled = false
                self.inGameBanner?.isHidden = true
                self.updateCurrentGameTime(nil)
            }
        }, errorBlock: {
            // Error
            DispatchQueue.main.async { [unowned self] in
                self.inGameBannerButton?.isHidden = true
                self.inGameBannerButton?.isEnabled = false
                self.inGameBanner?.isHidden = true
                self.updateCurrentGameTime(nil)
            }
        })
    }
    
    func updateCurrentGameTime(_ timer: Timer?) {
        DispatchQueue.main.async { [unowned self] in
            timer?.invalidate()
            self.currentGameRefreshCount += 1
            if (self.startDate != nil) {
                if self.startDate!.timeIntervalSinceNow > TimeInterval(-1800) {
                    // Less than 30 min
                    // Refresh every 60 sec
                    if self.currentGameRefreshCount >= 60 {
                        self.currentGameRefreshCount = 0
                        self.champName = nil
                        self.startDate = nil
                        self.getCurrentGame()
                    }
                } else if self.startDate!.timeIntervalSinceNow <= TimeInterval(-1800) || self.startDate!.timeIntervalSinceNow >= TimeInterval(-2100) {
                    // Between 30 and 35 min
                    // Refresh every 30 sec
                    if self.currentGameRefreshCount >= 30 {
                        self.currentGameRefreshCount = 0
                        self.champName = nil
                        self.startDate = nil
                        self.getCurrentGame()
                    }
                } else if self.startDate!.timeIntervalSinceNow < TimeInterval(-2100) {
                    // Greater than 35 min
                    // Refresh every 15 sec
                    if self.currentGameRefreshCount >= 15 {
                        self.currentGameRefreshCount = 0
                        self.champName = nil
                        self.startDate = nil
                        self.getCurrentGame()
                    }
                }
            } else {
                // Not in game
                // Refresh every 60 sec
                if self.currentGameRefreshCount >= 60 {
                    self.currentGameRefreshCount = 0
                    self.champName = nil
                    self.startDate = nil
                    self.getCurrentGame()
                }
            }
            if (self.champName != nil) && (self.startDate != nil) {
                self.inGameBanner?.champTime?.text = self.champName! + " - " + String(format: "%.0f:%02.0f", (self.startDate!.timeIntervalSinceNow * TimeInterval(-1)) / TimeInterval(60), (self.startDate!.timeIntervalSinceNow * TimeInterval(-1)).truncatingRemainder(dividingBy: 60))
                Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.updateCurrentGameTime(_:)), userInfo: nil, repeats: false)
            }
        }
    }
    
    func setupSummonerStats() {
        self.summonerStats.add(NSMutableDictionary(objects: ["Ranked Wins", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Ranked Losses", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["League Points", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal Takedowns", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal CS", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal Wins", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Kills", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Towers Destroyed", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Wins", "--"], forKeys: ["statTitle" as NSCopying, "statValue" as NSCopying]))
    }
    
    func downloadProfileIconCover() {
        DDragon().getProfileIcon(self.summoner.profileIconId, completion: { (profileIconURL) in
            // Circle profile pic
            self.profilePic?.layer.cornerRadius = (self.profilePic?.frame.size.height)! / 2
            
            self.cover?.setImageWith(URLRequest(url: profileIconURL), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                self.cover?.image = image
                self.profilePic?.image = image
                self.setShadowOnProfilePic()
            }, failure: { (request, response, error) in
                self.cover?.image = UIImage(named: "poroIcon")
                self.profilePic?.image = UIImage(named: "poroIcon")
                self.setShadowOnProfilePic()
            })
        })
    }
    
    func setShadowOnProfilePic() {
        // Rounded shadow on seperate UIView behind profile pic
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = UIBezierPath(roundedRect: self.profilePicShadow!.bounds, cornerRadius: self.profilePic!.layer.cornerRadius).cgPath
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        shadowLayer.shadowOpacity = 0.5
        shadowLayer.shadowRadius = 27.0
        //spread 15%
        self.profilePicShadow?.layer.addSublayer(shadowLayer)
        self.profilePicShadow?.layer.shouldRasterize = true
    }
    
    @IBAction func backButtonPressed() {
        delegate?.goBack()
    }
    
    @IBAction func addToRecentsPressed() {
        delegate?.addSummonerToRecents()
    }
    
    // MARK: - Graph Delegate
    
    // MARK: - Graph Data Source
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        // Anywhere between 250 - 500 points
        return Int(arc4random_uniform(250) + 250)
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        // Anywhere between 50 - 100
        return CGFloat(arc4random_uniform(50) + 50)
    }
    
    // MARK: - Collection view data source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.summonerStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileStats", for: indexPath) as! ProfileView_Header_StatsCell
        
        if indexPath.row == 0 {
            cell.leftBorder?.isHidden = true
        } else {
            cell.leftBorder?.isHidden = false
        }
        if indexPath.row == self.summonerStats.count - 1 {
            cell.rightBorder?.isHidden = true
        } else {
            cell.rightBorder?.isHidden = false
        }
        
        let summonerStats = self.summonerStats[indexPath.row] as! [String: String]
        cell.statTitle?.text = summonerStats["statTitle"]
        cell.statValue?.text = summonerStats["statValue"]
        
        return cell
    }
}
