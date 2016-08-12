//
//  Profile_RecentGames.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/12/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_RecentGames: MainTableViewController {
    var summoner = SummonerDto()
    var recentGameList = [GameDto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentGamesListCell", for: indexPath) as! Profile_RecentGames_Cell
        // Configure the cell...

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
