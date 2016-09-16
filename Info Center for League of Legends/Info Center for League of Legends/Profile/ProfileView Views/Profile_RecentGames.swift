//
//  Profile_RecentGames.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/12/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import JSBadgeView

class Profile_RecentGames: MainTableViewController {
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
        
        GameEndpoint().getRecentGamesBySummonerId(summonerId: summoner.summonerId, completion: { (recentGamesMap) in
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
        cell.item1?.image = nil
        cell.item2?.image = nil
        cell.item3?.image = nil
        cell.item4?.image = nil
        cell.item5?.image = nil
        cell.item6?.image = nil
        cell.item7?.image = nil
        
        // Configure the cell...
        StaticDataEndpoint().getChampionInfoById(champId: recentGameList[indexPath.row].championId, championData: .Image, completion: { (champion) in
            DDragon().getChampionSquareArt(fullImageName: champion.image!.full, completion: { (champSquareArtUrl) in
                cell.champIcon?.setImageWith(champSquareArtUrl)
            })
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
            cell.gameType?.text = recentGameList[indexPath.row].subType
            break
        case "TUTORIAL_GAME":
            cell.gameType?.text = "Tutorial"
            break
        default:
            break
        }
        
        StaticDataEndpoint().getSpellInfoById(spellId: recentGameList[indexPath.row].spell1, spellData: .image, completion: { (spellInfo) in
            DDragon().getSummonerSpellIcon(fullImageName: spellInfo.image!.full, completion: { (spellIconUrl) in
                cell.summonerSpell1?.setImageWith(spellIconUrl)
            })
        }, notFound: {
            // ???
        }) {
            // Error
        }
        StaticDataEndpoint().getSpellInfoById(spellId: recentGameList[indexPath.row].spell2, spellData: .image, completion: { (spellInfo) in
            DDragon().getSummonerSpellIcon(fullImageName: spellInfo.image!.full, completion: { (spellIconUrl) in
                cell.summonerSpell2?.setImageWith(spellIconUrl)
            })
        }, notFound: {
            // ???
        }) {
            // Error
        }
        
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
        DDragon().getUserInterfaceIcons(type: .minion) { (uiIconUrl) in
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
        DDragon().getUserInterfaceIcons(type: .gold) { (uiIconUrl) in
            cell.goldIcon?.setImageWith(uiIconUrl)
        }
        cell.gold?.text = String(gold)
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
