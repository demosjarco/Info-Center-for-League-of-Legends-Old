//
//  Profile_Runes.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_Runes: MainTableViewController {
    var summoner = SummonerDto()
    var runeList = [RunePageDto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        
        SummonerEndpoint().getRunesForSummonerIds([summoner.summonerId], completion: { (summonerMap) in
            self.runeList = summonerMap.values.first!.pages
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
        return runeList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "runePageCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = runeList[indexPath.row].name
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showRunesPageDetail" {
            
        }
    }
}
