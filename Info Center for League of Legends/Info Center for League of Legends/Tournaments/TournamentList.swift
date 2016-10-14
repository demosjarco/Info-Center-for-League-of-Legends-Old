//
//  TournamentList.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 9/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase

class TournamentList: UITableViewController {
    var myTournaments = [[String: AnyObject]]()
    var publicTournaments = [[String: AnyObject]]()
    
    var tournamentAddedRef = FIRDatabaseReference()
    var tournamentChangedRef = FIRDatabaseReference()
    var tournamentRemovedRef = FIRDatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            self.tournamentAddedRef.removeAllObservers()
            self.tournamentChangedRef.removeAllObservers()
            self.tournamentRemovedRef.removeAllObservers()
            
            if user != nil {
                self.tournamentAddedRef = FIRDatabase.database().reference().child("tournaments")
                self.tournamentAddedRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
                    if self.checkIfMyTournament(snapshot: snapshot) {
                        self.myTournaments.append(snapshot.value as! [String: AnyObject])
                        let tempArray = self.myTournaments as NSArray
                        self.tableView.insertRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 0)], with: .automatic)
                    } else {
                        self.publicTournaments.append(snapshot.value as! [String: AnyObject])
                        let tempArray = self.publicTournaments as NSArray
                        self.tableView.insertRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 1)], with: .automatic)
                    }
                })
                
                self.tournamentChangedRef = FIRDatabase.database().reference().child("tournaments")
                self.tournamentAddedRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
                    let tempTournament = snapshot.value as! [String: AnyObject]
                    var index = 0
                    if self.checkIfMyTournament(snapshot: snapshot) {
                        for tournament in self.myTournaments {
                            if tournament["tournamentId"] as! String == tempTournament["tournamentId"] as! String {
                                break
                            } else {
                                index += 1
                            }
                        }
                        self.myTournaments[index] = snapshot.value as! [String: AnyObject]
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    } else {
                        for tournament in self.publicTournaments {
                            if tournament["tournamentId"] as! String == tempTournament["tournamentId"] as! String {
                                break
                            } else {
                                index += 1
                            }
                        }
                        self.publicTournaments[index] = snapshot.value as! [String: AnyObject]
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
                    }
                })
                
                self.tournamentRemovedRef = FIRDatabase.database().reference().child("tournaments")
                self.tournamentAddedRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
                    if self.checkIfMyTournament(snapshot: snapshot) {
                        let tempArray = self.myTournaments as NSArray
                        self.myTournaments.remove(at: tempArray.index(of: snapshot.value as! [String: AnyObject]))
                        self.tableView.deleteRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 0)], with: .automatic)
                    } else {
                        let tempArray = self.publicTournaments as NSArray
                        self.publicTournaments.remove(at: tempArray.index(of: snapshot.value as! [String: AnyObject]))
                        self.tableView.deleteRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 1)], with: .automatic)
                    }
                })
            }
        })
    }
    
    func checkIfMyTournament(snapshot: FIRDataSnapshot) -> Bool {
        var myTournament = false
        let admin = snapshot.childSnapshot(forPath: "createdBy").value as! String
        if admin == FIRAuth.auth()?.currentUser?.uid {
            myTournament = true
        }
        
        let participants = snapshot.childSnapshot(forPath: "participants")
        if participants.hasChild("pending") {
            let pending = participants.childSnapshot(forPath: "pending").value as! [String: [String: AnyObject]]
            for player in pending.values {
                let userId = player["userId"] as! String
                if userId == FIRAuth.auth()?.currentUser?.uid {
                    myTournament = true
                }
            }
        }
        
        let teams = participants.childSnapshot(forPath: "teams").value as! [String: [String: AnyObject]]
        for team in teams.values {
            let players = team["players"] as! [String: [String: AnyObject]]
            for player in players.values {
                if player["userId"] != nil {
                    if player["userId"] as? String == FIRAuth.auth()?.currentUser?.uid {
                        myTournament = true
                    }
                }
            }
        }
        
        return myTournament
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
        if section == 0 {
            return myTournaments.count
        } else {
            return publicTournaments.count
        }
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
