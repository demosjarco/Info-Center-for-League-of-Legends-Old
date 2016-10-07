//
//  TournamentList.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 9/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class TournamentList: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh()
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        //FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Tournaments"
        } else {
            return "Public Tournaments"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentCell", for: indexPath) as! TournamentListCell

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    /*
    // Custom edit buttons
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        /*let editAction = UITableViewRowAction(style: .Normal, title: "Edit") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
         //TODO: edit the row at indexPath here
         }
         editAction.backgroundColor = UIColor.blueColor()
         
         
         let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (rowAction:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
         //TODO: Delete the row at indexPath here
         }
         deleteAction.backgroundColor = UIColor.redColor()
         
         return [editAction,deleteAction]*/
        <#code#>
    }*/

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
