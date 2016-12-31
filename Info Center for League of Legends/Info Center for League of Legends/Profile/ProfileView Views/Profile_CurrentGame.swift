//
//  Profile_CurrentGame.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_CurrentGame: MainTableViewController {
    var summoner = SummonerDto()
    
    var bans = [BannedChampion]()
    var participantsBlue = [CurrentGameParticipant]()
    var participantsRed = [CurrentGameParticipant]()
    var currentGameRefreshCount = 0
    var startDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh()
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        
        CurrentGameEndpoint().getSpectatorGameInfo(self.summoner.summonerId, completion: { (game) in
            self.startDate = game.gameStartTime
            self.bans = game.bannedChampions
            
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
            
            self.title = mapName + " - " + gameType
            
            // Get champ info
            for participant in game.participants {
                if participant.teamId == 100 {
                    // Blue Team
                    self.participantsBlue.append(participant)
                } else {
                    // Red Team
                    self.participantsRed.append(participant)
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }, notFound: {
            // ??
        }) {
            // Error
        }
    }

    /*
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
    }*/
    
    /*sfunc updateCurrentGameTime(_ timer: Timer?) {
        timer?.invalidate()
        self.currentGameRefreshCount += 1
        if (startDate != nil) {
            if startDate!.timeIntervalSinceNow > TimeInterval(-1800) {
                // Less than 30 min
                // Refresh every 60 sec
                if self.currentGameRefreshCount >= 60 {
                    self.currentGameRefreshCount = 0
                    self.champName = nil
                    self.startDate = nil
                    self.getCurrentGame()
                }
            } else if startDate!.timeIntervalSinceNow <= TimeInterval(-1800) || startDate!.timeIntervalSinceNow >= TimeInterval(-2100) {
                // Between 30 and 35 min
                // Refresh every 30 sec
                if self.currentGameRefreshCount >= 30 {
                    self.currentGameRefreshCount = 0
                    self.champName = nil
                    self.startDate = nil
                    self.getCurrentGame()
                }
            } else if startDate!.timeIntervalSinceNow < TimeInterval(-2100) {
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
        if (champName != nil) && (startDate != nil) {
            self.inGameBanner?.champTime?.text = champName! + " - " + String(format: "%.0fm", (startDate!.timeIntervalSinceNow * TimeInterval(-1)) / TimeInterval(60))
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.updateCurrentGameTime(_:)), userInfo: nil, repeats: false)
        }
    }*/

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return participantsBlue.count
        } else {
            return participantsRed.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamHeader") as! Profile_CurrentGame_Header
        
        if section == 0 {
            // Blue team
            cell.teamName?.text = "Blue Team"
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.75, alpha: 1.0)
        } else {
            // Red team
            cell.teamName?.text = "Red Team"
            cell.backgroundColor = UIColor(red: 0.75, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gamePlayer", for: indexPath) as! Profile_CurrentGame_Cell
        // Configure the cell...
        if indexPath.section == 0 {
            // Blue team
            
            // Champ Icon
            StaticDataEndpoint().getChampionInfoById(Int(participantsBlue[indexPath.row].championId), championData: .Image, completion: { (champInfo) in
                // Use the new LCU icon if exists
                if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.participantsBlue[indexPath.row].championId)) {
                    cell.champIcon?.image = champIcon
                } else {
                    DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                        cell.champIcon?.setImageWith(champSquareArtUrl)
                    })
                }
            }, notFound: {
                // ???
            }, errorBlock: {
                // Error
            })
            // Champion Mastery
            
            // Spell 1
            StaticDataEndpoint().getSpellInfoById(Int(participantsBlue[indexPath.row].spell1Id), spellData: .image, completion: { (spellInfo) in
                DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                    cell.spell1?.setImageWith(spellIconUrl)
                })
            }, notFound: {
                // ??
            }, errorBlock: { 
                // Error
            })
            // Spell 2
            StaticDataEndpoint().getSpellInfoById(Int(participantsBlue[indexPath.row].spell2Id), spellData: .image, completion: { (spellInfo) in
                DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                    cell.spell2?.setImageWith(spellIconUrl)
                })
            }, notFound: {
                // ??
            }, errorBlock: {
                // Error
            })
            
            // Keystone Mastery
            for mastery in participantsBlue[indexPath.row].masteries {
                if mastery.masteryId > 6160 && mastery.masteryId < 6200 {
                    DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                        cell.keyStoneMastery?.setImageWith(masteryIconUrl)
                    })
                } else if mastery.masteryId > 6260 && mastery.masteryId < 6300 {
                    DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                        cell.keyStoneMastery?.setImageWith(masteryIconUrl)
                    })
                } else if mastery.masteryId > 6360 && mastery.masteryId < 6400 {
                    DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                        cell.keyStoneMastery?.setImageWith(masteryIconUrl)
                    })
                }
            }
            
            // Summoner Name
            cell.summonerName?.text = participantsBlue[indexPath.row].summonerName
            
            // Bans
            switch indexPath.row {
            case 2:
                StaticDataEndpoint().getChampionInfoById(Int(bans[0].championId), championData: .Image, completion: { (champInfo) in
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[0].championId)) {
                        cell.champBan?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champBan?.setImageWith(champSquareArtUrl)
                        })
                    }
                }, notFound: { 
                    // ??
                }, errorBlock: { 
                    // Error
                })
                break
            case 3:
                StaticDataEndpoint().getChampionInfoById(Int(bans[2].championId), championData: .Image, completion: { (champInfo) in
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[2].championId)) {
                        cell.champBan?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champBan?.setImageWith(champSquareArtUrl)
                        })
                    }
                }, notFound: {
                    // ??
                }, errorBlock: {
                    // Error
                })
                break
            case 4:
                StaticDataEndpoint().getChampionInfoById(Int(bans[4].championId), championData: .Image, completion: { (champInfo) in
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[4].championId)) {
                        cell.champBan?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champBan?.setImageWith(champSquareArtUrl)
                        })
                    }
                }, notFound: {
                    // ??
                }, errorBlock: {
                    // Error
                })
                break
            default:
                break
            }
        } else {
            // Red team
            
            // Champion Icon
            StaticDataEndpoint().getChampionInfoById(Int(participantsRed[indexPath.row].championId), championData: .Image, completion: { (champInfo) in
                // Use the new LCU icon if exists
                if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.participantsRed[indexPath.row].championId)) {
                    cell.champIcon?.image = champIcon
                } else {
                    DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                        cell.champIcon?.setImageWith(champSquareArtUrl)
                    })
                }
            }, notFound: {
                // ???
            }, errorBlock: {
                // Error
            })
            // Champion Mastery
            
            // Spell 1
            StaticDataEndpoint().getSpellInfoById(Int(participantsRed[indexPath.row].spell1Id), spellData: .image, completion: { (spellInfo) in
                DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                    cell.spell1?.setImageWith(spellIconUrl)
                })
            }, notFound: {
                // ??
            }, errorBlock: {
                // Error
            })
            // Spell 2
            StaticDataEndpoint().getSpellInfoById(Int(participantsRed[indexPath.row].spell2Id), spellData: .image, completion: { (spellInfo) in
                DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                    cell.spell2?.setImageWith(spellIconUrl)
                })
            }, notFound: {
                // ??
            }, errorBlock: {
                // Error
            })
            
            // Keystone Mastery
            for mastery in participantsRed[indexPath.row].masteries {
                if mastery.masteryId > 6160 && mastery.masteryId < 6200 {
                    DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                        cell.keyStoneMastery?.setImageWith(masteryIconUrl)
                    })
                } else if mastery.masteryId > 6260 && mastery.masteryId < 6300 {
                    DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                        cell.keyStoneMastery?.setImageWith(masteryIconUrl)
                    })
                } else if mastery.masteryId > 6360 && mastery.masteryId < 6400 {
                    DDragon().getMasteryIcon(mastery.masteryId, gray: false, completion: { (masteryIconUrl) in
                        cell.keyStoneMastery?.setImageWith(masteryIconUrl)
                    })
                }
            }
            
            // Summoner Name
            cell.summonerName?.text = participantsRed[indexPath.row].summonerName
            
            // Bans
            switch indexPath.row {
            case 2:
                StaticDataEndpoint().getChampionInfoById(Int(bans[1].championId), championData: .Image, completion: { (champInfo) in
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[1].championId)) {
                        cell.champBan?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champBan?.setImageWith(champSquareArtUrl)
                        })
                    }
                }, notFound: {
                    // ??
                }, errorBlock: {
                    // Error
                })
                break
            case 3:
                StaticDataEndpoint().getChampionInfoById(Int(bans[3].championId), championData: .Image, completion: { (champInfo) in
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[3].championId)) {
                        cell.champBan?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champBan?.setImageWith(champSquareArtUrl)
                        })
                    }
                }, notFound: {
                    // ??
                }, errorBlock: {
                    // Error
                })
                break
            case 4:
                StaticDataEndpoint().getChampionInfoById(Int(bans[5].championId), championData: .Image, completion: { (champInfo) in
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[5].championId)) {
                        cell.champBan?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champBan?.setImageWith(champSquareArtUrl)
                        })
                    }
                }, notFound: {
                    // ??
                }, errorBlock: {
                    // Error
                })
                break
            default:
                break
            }
        }

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
