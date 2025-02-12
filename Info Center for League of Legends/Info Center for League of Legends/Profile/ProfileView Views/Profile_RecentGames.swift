//
//  Profile_RecentGames.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/12/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase
import JSBadgeView
import SafariServices

class Profile_RecentGames: MainTableViewController, SFSafariViewControllerDelegate {
    var summoner = SummonerDto()
    var recentGameList = [GameDto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        
        GameEndpoint().getRecentGamesBySummonerId(summoner.summonerId, completion: { (recentGamesMap) in
            self.recentGameList = recentGamesMap.games
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.refreshControl?.endRefreshing()
        }) {
            // Error
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentGameList.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.lightText
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "RECENT GAMES (LAST " + String(recentGameList.count) + " PLAYED)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentGamesListCell", for: indexPath) as! Profile_RecentGames_Cell
        // Clear the cell
        cell.champIcon?.image = nil
        cell.summonerSpell1?.image = nil
        cell.summonerSpell2?.image = nil
        cell.item0?.image = nil
        cell.item1?.image = nil
        cell.item2?.image = nil
        cell.item3?.image = nil
        cell.item4?.image = nil
        cell.item5?.image = nil
        cell.item6?.image = nil
        
        // Configure the cell...
        StaticDataEndpoint().getChampionInfoById(recentGameList[indexPath.row].championId, championData: .Image, completion: { (champion) in
            // Use the new LCU icon if exists
            if let champIcon = DDragon().getLcuChampionSquareArt(self.recentGameList[indexPath.row].championId) {
                cell.champIcon?.image = champIcon
            } else {
                DDragon().getChampionSquareArt(champion.image!.full, completion: { (champSquareArtUrl) in
                    cell.champIcon?.setImageWith(champSquareArtUrl)
                })
            }
        }, notFound: {
            // ???
        }) {
            // Error
        }
        
        let champLevelBadge = JSBadgeView(parentView: cell.badgeHolder, alignment: .bottomRight)
        champLevelBadge?.badgeText = String(recentGameList[indexPath.row].stats.level!)
        champLevelBadge?.badgeTextFont = UIFont.preferredFont(forTextStyle: .callout)
        champLevelBadge?.badgeBackgroundColor = UIColor(red: CGFloat(1.0/255.0), green: CGFloat(10.0/255.0), blue: CGFloat(19.0/255.0), alpha: 1)
        champLevelBadge?.badgeStrokeWidth = CGFloat(1.0)
        champLevelBadge?.badgeStrokeColor = UIColor(red: CGFloat(200.0/255.0), green: CGFloat(156.0/255.0), blue: CGFloat(59.0/255.0), alpha: 1)
        champLevelBadge?.badgeTextColor = UIColor(red: CGFloat(161.0/255.0), green: CGFloat(155.0/255.0), blue: CGFloat(140.0/255.0), alpha: 1)
        
        if recentGameList[indexPath.row].stats.win {
            cell.gameOutcome?.text = "VICTORY"
            cell.gameOutcome?.textColor = UIColor(red: CGFloat(55.0/255.0), green: CGFloat(203.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1)
        } else {
            cell.gameOutcome?.text = "DEFEAT"
            cell.gameOutcome?.textColor = UIColor(red: CGFloat(248.0/255.0), green: CGFloat(34.0/255.0), blue: CGFloat(70.0/255.0), alpha: 1)
        }
        
        switch recentGameList[indexPath.row].gameType {
        case "CUSTOM_GAME":
            cell.gameType?.text = "Custom"
            break
        case "MATCHED_GAME":
            // Nice text
            switch recentGameList[indexPath.row].subType {
            case "RANKED_SOLO_5x5":
                cell.gameType?.text = "Ranked Solo"
                break
            case "RANKED_PREMADE_5x5":
                cell.gameType?.text = "Ranked 5s"
                break
            case "RANKED_TEAM_3x3":
                cell.gameType?.text = "Ranked 3s"
                break
            case "RANKED_FLEX_SR":
                cell.gameType?.text = "Ranked Flex"
                break
            case "RANKED_FLEX_TT":
                cell.gameType?.text = "Ranked Flex"
                break
            case "KING_PORO":
                cell.gameType?.text = "Poro King"
                break
            case "NORMAL":
                cell.gameType?.text = "Normal"
                break
            case "ARAM_UNRANKED_5x5":
                cell.gameType?.text = "ARAM"
                break
            case "SIEGE":
                cell.gameType?.text = "Nexus Seige"
                break
            case "NIGHTMARE_BOT":
                cell.gameType?.text = "Doom Bots"
                break
            default:
                cell.gameType?.text = recentGameList[indexPath.row].subType
                break
            }
            break
        case "TUTORIAL_GAME":
            cell.gameType?.text = "Tutorial"
            break
        default:
            break
        }
        
        StaticDataEndpoint().getSpellInfoById(recentGameList[indexPath.row].spell1, spellData: .image, completion: { (spellInfo) in
            DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                cell.summonerSpell1?.setImageWith(spellIconUrl)
            })
        }, notFound: {
            // ???
        }) {
            // Error
        }
        StaticDataEndpoint().getSpellInfoById(recentGameList[indexPath.row].spell2, spellData: .image, completion: { (spellInfo) in
            DDragon().getSummonerSpellIcon(spellInfo.image!.full, completion: { (spellIconUrl) in
                cell.summonerSpell2?.setImageWith(spellIconUrl)
            })
        }, notFound: {
            // ???
        }) {
            // Error
        }
        
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item0) { (itemIconUrl) in
            cell.item0?.setImageWith(itemIconUrl)
        }
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item1) { (itemIconUrl) in
            cell.item1?.setImageWith(itemIconUrl)
        }
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item2) { (itemIconUrl) in
            cell.item2?.setImageWith(itemIconUrl)
        }
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item3) { (itemIconUrl) in
            cell.item3?.setImageWith(itemIconUrl)
        }
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item4) { (itemIconUrl) in
            cell.item4?.setImageWith(itemIconUrl)
        }
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item5) { (itemIconUrl) in
            cell.item5?.setImageWith(itemIconUrl)
        }
        DDragon().getItemIcon(recentGameList[indexPath.row].stats.item6) { (itemIconUrl) in
            cell.item6?.setImageWith(itemIconUrl)
        }
        
        cell.ipEarned?.text = "+" + String(recentGameList[indexPath.row].ipEarned) + " IP"
        
        var kills = 0
        if recentGameList[indexPath.row].stats.championsKilled != nil {
            kills = recentGameList[indexPath.row].stats.championsKilled!
        }
        var deaths = 0
        if recentGameList[indexPath.row].stats.numDeaths != nil {
            deaths = recentGameList[indexPath.row].stats.numDeaths!
        }
        var assists = 0
        if recentGameList[indexPath.row].stats.assists != nil {
            assists = recentGameList[indexPath.row].stats.assists!
        }
        cell.kda?.text = String(kills) + " /" + String(deaths) + " /" + String(assists)
        DDragon().getUserInterfaceIcons(.minion) { (uiIconUrl) in
            cell.creepScoreIcon?.setImageWith(uiIconUrl)
        }
        var cs = 0
        if recentGameList[indexPath.row].stats.minionsKilled != nil {
            cs += recentGameList[indexPath.row].stats.minionsKilled!
        }
        if recentGameList[indexPath.row].stats.neutralMinionsKilled != nil {
            cs += recentGameList[indexPath.row].stats.neutralMinionsKilled!
        }
        cell.creepScore?.text = String(cs)
        var gold = 0
        if recentGameList[indexPath.row].stats.goldEarned != nil {
            gold = recentGameList[indexPath.row].stats.goldEarned!
        }
        DDragon().getUserInterfaceIcons(.gold) { (uiIconUrl) in
            cell.goldIcon?.setImageWith(uiIconUrl)
        }
        cell.gold?.text = String(gold)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FIRDatabase.database().reference().child("news_languages").observe(FIRDataEventType.value, with: { (snapshot) in
            let languages = snapshot.value as! [String: AnyObject]
            let languagesForRegion = languages[Endpoints().getRegion()] as! [String]
            
            var region = ""
            switch Endpoints().getRegion() {
            case "br":
                region = Endpoints.platformId.br.rawValue
                break
            case "eune":
                region = Endpoints.platformId.eune.rawValue
                break
            case "euw":
                region = Endpoints.platformId.euw.rawValue
                break
            case "jp":
                region = Endpoints.platformId.jp.rawValue
                break
            case "kr":
                region = Endpoints.platformId.kr.rawValue
                break
            case "lan":
                region = Endpoints.platformId.lan.rawValue
                break
            case "las":
                region = Endpoints.platformId.las.rawValue
                break
            case "na":
                region = Endpoints.platformId.na.rawValue
                break
            case "oce":
                region = Endpoints.platformId.oce.rawValue
                break
            case "ru":
                region = Endpoints.platformId.ru.rawValue
                break
            case "tr":
                region = Endpoints.platformId.br.rawValue
                break
            default:
                region = ""
                break
            }
            
            var language = ""
            if languagesForRegion.contains(Locale.preferredLanguages[0].components(separatedBy: "-")[0]) {
                language = Locale.preferredLanguages[0].components(separatedBy: "-")[0]
            } else {
                language = languagesForRegion[0]
            }
            let matchDetailScreen = SFSafariViewController(url: URL(string: "http://matchhistory." + Endpoints().getRegion() + ".leagueoflegends.com/" + language + "/#match-details/" + region + "/" + String(self.recentGameList[indexPath.row].gameId) + "/0")!, entersReaderIfAvailable: false)
            matchDetailScreen.delegate = self
            self.present(matchDetailScreen, animated: true, completion: {
                tableView.deselectRow(at: indexPath, animated: true)
            })
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
