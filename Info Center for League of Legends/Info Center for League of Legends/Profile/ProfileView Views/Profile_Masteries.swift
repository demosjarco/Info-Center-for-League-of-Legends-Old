//
//  Profile_Masteries.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/21/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_Masteries: MainTableViewController {
    var summoner = SummonerDto()
    var masteryList = [MasteryPageDto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        
        SummonerEndpoint().getMasteriesForSummonerIds([summoner.summonerId], completion: { (summonerMap) in
            self.masteryList = summonerMap.values.first!.pages
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.refreshControl?.endRefreshing()
        }, errorBlock: {
            // Error
            self.refreshControl?.endRefreshing()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masteryList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "masteryPageCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = masteryList[indexPath.row].name

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showMasteriesPageDetail" {
            let destination = segue.destination as! Profile_Masteries_MasteriesView
            destination.summoner = self.summoner
            destination.pageId = masteryList[tableView.indexPathForSelectedRow!.row].masteryPageId
        }
    }
}
