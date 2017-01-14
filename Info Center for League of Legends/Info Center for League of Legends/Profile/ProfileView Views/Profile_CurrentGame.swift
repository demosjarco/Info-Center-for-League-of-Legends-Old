//
//  Profile_CurrentGame.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

protocol Profile_CurrentGameDelegate {
    func showParticiapantProfileInfo(_ summoner: SummonerDto)
}

class Profile_CurrentGame: MainTableViewController {
    var delegate:Profile_CurrentGameDelegate?
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
            
            self.participantsBlue = [CurrentGameParticipant]()
            self.participantsRed = [CurrentGameParticipant]()
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
                self.updateCurrentGameTime(nil)
            }
        }, notFound: {
            // ??
        }) {
            // Error
        }
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
                        self.checkIfGameStillOn()
                    }
                } else if self.startDate!.timeIntervalSinceNow <= TimeInterval(-1800) || self.startDate!.timeIntervalSinceNow >= TimeInterval(-2100) {
                    // Between 30 and 35 min
                    // Refresh every 30 sec
                    if self.currentGameRefreshCount >= 30 {
                        self.currentGameRefreshCount = 0
                        self.checkIfGameStillOn()
                    }
                } else if self.startDate!.timeIntervalSinceNow < TimeInterval(-2100) {
                    // Greater than 35 min
                    // Refresh every 15 sec
                    if self.currentGameRefreshCount >= 15 {
                        self.currentGameRefreshCount = 0
                        self.checkIfGameStillOn()
                    }
                }
                
                self.navigationItem.prompt = String(format: "%.0f:%02.0f", (self.startDate!.timeIntervalSinceNow * TimeInterval(-1)) / TimeInterval(60), (self.startDate!.timeIntervalSinceNow * TimeInterval(-1)).truncatingRemainder(dividingBy: 60))
                Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.updateCurrentGameTime(_:)), userInfo: nil, repeats: false)
            } else {
                // Not in game
                // Refresh every 60 sec
                if self.currentGameRefreshCount >= 60 {
                    self.currentGameRefreshCount = 0
                    self.checkIfGameStillOn()
                }
            }
        }
    }
    
    func checkIfGameStillOn() {
        CurrentGameEndpoint().getSpectatorGameInfo(self.summoner.summonerId, completion: { (game) in
            // In game
            self.updateCurrentGameTime(nil)
        }, notFound: { 
            // No longer in game
            self.startDate = nil
            self.navigationItem.prompt = "Game Ended - " + self.navigationItem.prompt!
        }) { 
            // Error
        }
    }

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
                autoreleasepool(invoking: { ()
                    // Use the new LCU icon if exists
                    if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.participantsBlue[indexPath.row].championId)) {
                        cell.champIcon?.image = champIcon
                    } else {
                        DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                            cell.champIcon?.setImageWith(champSquareArtUrl)
                        })
                    }
                })
            }, notFound: {
                // ???
            }, errorBlock: {
                // Error
            })
            // Champion Mastery
            ChampionMasteryEndpoint().getChampByIdBySummonerId(participantsBlue[indexPath.row].championId, playerId: participantsBlue[indexPath.row].summonerId, completion: { (champion) in
                cell.champMastery?.image = UIImage(named: "rank" + String(champion.championLevel))
            }, notFound: {
                // No champion mastery for it
                cell.champMastery?.image = nil
            }, errorBlock: { 
                // Error
                cell.champMastery?.image = nil
            })
            
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
            
            // Current Season
            LeagueEndpoint().getLeagueEntryBySummonerIds([participantsBlue[indexPath.row].summonerId], completion: { (summonerMap) in
                autoreleasepool(invoking: { ()
                    // Ranked
                    let currentSummoner = summonerMap.values.first
                    
                    var highestTier: Int = 7
                    var highestTierSpelledOut: String = ""
                    var highestDivision: Int = 6
                    var highestDivisionRoman: String = ""
                    
                    if (currentSummoner != nil) {
                        for league in currentSummoner! {
                            autoreleasepool(invoking: { ()
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
                                    cell.currentSeasonRank?.image = UIImage(named: highestTierSpelledOut.lowercased())
                                } else {
                                    // Diamond and lower
                                    // Use division
                                    cell.currentSeasonRank?.image = UIImage(named: highestTierSpelledOut.lowercased() + "_" + highestDivisionRoman.lowercased())
                                }
                            })
                        }
                    } else {
                        // Error
                        cell.currentSeasonRank?.image = UIImage(named: "provisional")
                    }
                })
            }, notFound: {
                // Unranked
                cell.currentSeasonRank?.image = UIImage(named: "provisional")
            }, errorBlock: {
                // Error
                cell.currentSeasonRank?.image = UIImage(named: "provisional")
            })
            
            // Bans
            if bans.count == 6 {
                switch indexPath.row {
                case 2:
                    StaticDataEndpoint().getChampionInfoById(Int(bans[0].championId), championData: .Image, completion: { (champInfo) in
                        autoreleasepool(invoking: { ()
                            // Use the new LCU icon if exists
                            if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[0].championId)) {
                                cell.champBan?.image = champIcon
                            } else {
                                DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                                    cell.champBan?.setImageWith(champSquareArtUrl)
                                })
                            }
                        })
                    }, notFound: {
                        // ??
                    }, errorBlock: {
                        // Error
                    })
                    break
                case 3:
                    StaticDataEndpoint().getChampionInfoById(Int(bans[2].championId), championData: .Image, completion: { (champInfo) in
                        autoreleasepool(invoking: { ()
                            // Use the new LCU icon if exists
                            if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[2].championId)) {
                                cell.champBan?.image = champIcon
                            } else {
                                DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                                    cell.champBan?.setImageWith(champSquareArtUrl)
                                })
                            }
                        })
                    }, notFound: {
                        // ??
                    }, errorBlock: {
                        // Error
                    })
                    break
                case 4:
                    StaticDataEndpoint().getChampionInfoById(Int(bans[4].championId), championData: .Image, completion: { (champInfo) in
                        autoreleasepool(invoking: { ()
                            // Use the new LCU icon if exists
                            if let champIcon = DDragon().getLcuChampionSquareArt(champId: Int(self.bans[4].championId)) {
                                cell.champBan?.image = champIcon
                            } else {
                                DDragon().getChampionSquareArt(champInfo.image!.full, completion: { (champSquareArtUrl) in
                                    cell.champBan?.setImageWith(champSquareArtUrl)
                                })
                            }
                        })
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
            ChampionMasteryEndpoint().getChampByIdBySummonerId(participantsRed[indexPath.row].championId, playerId: participantsRed[indexPath.row].summonerId, completion: { (champion) in
                cell.champMastery?.image = UIImage(named: "rank" + String(champion.championLevel))
            }, notFound: {
                // No champion mastery for it
                cell.champMastery?.image = nil
            }, errorBlock: {
                // Error
                cell.champMastery?.image = nil
            })
            
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
            
            LeagueEndpoint().getLeagueEntryBySummonerIds([participantsRed[indexPath.row].summonerId], completion: { (summonerMap) in
                // Ranked
                let currentSummoner = summonerMap.values.first
                
                var highestTier: Int = 7
                var highestTierSpelledOut: String = ""
                var highestDivision: Int = 6
                var highestDivisionRoman: String = ""
                
                if (currentSummoner != nil) {
                    for league in currentSummoner! {
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
                            cell.currentSeasonRank?.image = UIImage(named: highestTierSpelledOut.lowercased())
                        } else {
                            // Diamond and lower
                            // Use division
                            cell.currentSeasonRank?.image = UIImage(named: highestTierSpelledOut.lowercased() + "_" + highestDivisionRoman.lowercased())
                        }
                    }
                } else {
                    // Error
                    cell.currentSeasonRank?.image = UIImage(named: "provisional")
                }
            }, notFound: {
                // Unranked
                cell.currentSeasonRank?.image = UIImage(named: "provisional")
            }, errorBlock: {
                // Error
                cell.currentSeasonRank?.image = UIImage(named: "provisional")
            })
            
            // Bans
            if bans.count == 6 {
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
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        autoreleasepool(invoking: { ()
            let temp = SummonerDto()
            
            if indexPath.section == 0 {
                temp.summonerId = participantsBlue[indexPath.row].summonerId
                temp.profileIconId = Int(participantsBlue[indexPath.row].profileIconId)
                temp.name = participantsBlue[indexPath.row].summonerName
            } else {
                temp.summonerId = participantsRed[indexPath.row].summonerId
                temp.profileIconId = Int(participantsRed[indexPath.row].profileIconId)
                temp.name = participantsRed[indexPath.row].summonerName
            }
            
            self.delegate?.showParticiapantProfileInfo(temp)
            self.closeView()
        })
    }
}
