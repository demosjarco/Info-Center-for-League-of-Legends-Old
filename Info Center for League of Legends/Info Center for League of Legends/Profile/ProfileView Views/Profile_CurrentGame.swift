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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
