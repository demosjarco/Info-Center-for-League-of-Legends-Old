//
//  ProfileSearch.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ProfileSearch: MainTableViewController {
    var dbFilePath: String = String()
    var recentSummoners = [1, 2];
    var summonerInfoForSegue = ["blah": "blah", "blah2": 1]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ExistingAppChecker().checkIfAppSetup(viewController: self)

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refresh()
    }
    
    func refresh() {
        if initializeDb() {
            print("Initialized recent summoners database")
        }
        
        autoreleasepool { ()
            let db: FMDatabase = FMDatabase(path: dbFilePath)
        }
    }
    
    func initializeDb() -> Bool {
        let documentFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let dbfile = "/" + "recentSummoners.sqlite3";
        dbFilePath = documentFolderPath.appending(dbfile)
        
        if (!FileManager.default().fileExists(atPath: dbFilePath)) {
            let backupDbPath = Bundle.main().pathForResource("recentSummoners", ofType:"sqlite3")
            
            if (backupDbPath == nil) {
                return false
            } else {
                do {
                    try FileManager.default().copyItem(atPath: backupDbPath!, toPath:dbFilePath)
                } catch let error as NSError {
                    print("copy failed: \(error.localizedDescription)")
                    return false
                }
            }
        } else {
            /*do {
                try FileManager.default().removeItem(atPath: dbFilePath)
            } catch let error as NSError {
                print("delete failed: \(error.localizedDescription)")
            }*/
        }
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentProfileCell", for: indexPath)
        
        // Configure the cell...

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
