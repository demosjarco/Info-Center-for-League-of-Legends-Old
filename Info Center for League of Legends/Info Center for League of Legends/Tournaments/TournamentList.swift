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
    var myTournaments = [[String: Any]]()
    var publicTournaments = [[String: Any]]()
    
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
                self.tournamentAddedRef = FIRDatabase.database().reference().child("tournaments").child(Endpoints().getRegion()).child("tournamentList")
                self.tournamentAddedRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
                    if self.checkIfMyTournament(snapshot) {
                        self.myTournaments.append(snapshot.value as! [String: Any])
                        let tempArray = self.myTournaments as NSArray
                        self.tableView.insertRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: Any]), section: 0)], with: .automatic)
                    } else {
                        self.publicTournaments.append(snapshot.value as! [String: Any])
                        let tempArray = self.publicTournaments as NSArray
                        self.tableView.insertRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: Any]), section: 1)], with: .automatic)
                    }
                })
                
                self.tournamentChangedRef = FIRDatabase.database().reference().child("tournaments").child(Endpoints().getRegion()).child("tournamentList")
                self.tournamentAddedRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
                    let tempTournament = snapshot.value as! [String: Any]
                    var index = 0
                    if self.checkIfMyTournament(snapshot) {
                        for tournament in self.myTournaments {
                            if tournament["tournamentId"] as! String == tempTournament["tournamentId"] as! String {
                                break
                            } else {
                                index += 1
                            }
                        }
                        self.myTournaments[index] = snapshot.value as! [String: Any]
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    } else {
                        for tournament in self.publicTournaments {
                            if tournament["tournamentId"] as! String == tempTournament["tournamentId"] as! String {
                                break
                            } else {
                                index += 1
                            }
                        }
                        self.publicTournaments[index] = snapshot.value as! [String: Any]
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
                    }
                })
                
                self.tournamentRemovedRef = FIRDatabase.database().reference().child("tournaments").child(Endpoints().getRegion()).child("tournamentList")
                self.tournamentAddedRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
                    if self.checkIfMyTournament(snapshot) {
                        let tempArray = self.myTournaments as NSArray
                        self.myTournaments.remove(at: tempArray.index(of: snapshot.value as! [String: Any]))
                        self.tableView.deleteRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: Any]), section: 0)], with: .automatic)
                    } else {
                        let tempArray = self.publicTournaments as NSArray
                        self.publicTournaments.remove(at: tempArray.index(of: snapshot.value as! [String: Any]))
                        self.tableView.deleteRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: Any]), section: 1)], with: .automatic)
                    }
                })
            }
        })
    }
    
    func checkIfMyTournament(_ snapshot: FIRDataSnapshot) -> Bool {
        var myTournament = false
        let admin = snapshot.childSnapshot(forPath: "createdBy").value as! String
        if admin == FIRAuth.auth()?.currentUser?.uid {
            myTournament = true
        }
        
        let participants = snapshot.childSnapshot(forPath: "participants")
        if participants.hasChild("pending") {
            let pending = participants.childSnapshot(forPath: "pending").value as! [String: [String: Any]]
            for player in pending.values {
                let userId = player["userId"] as! String
                if userId == FIRAuth.auth()?.currentUser?.uid {
                    myTournament = true
                }
            }
        }
        
        let teams = participants.childSnapshot(forPath: "teams").value as! [String: [String: Any]]
        for team in teams.values {
            let players = team["players"] as! [String: [String: Any]]
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
    
    @IBAction func createTournament() {
        if FIRAuth.auth()!.currentUser!.isAnonymous {
            let alert = UIAlertController(title: "Error", message: "You can't create a tournament as an anonymous user. Please go to account in the top left and tap on the account type row to upgrade your account. Don't worry, its free.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: {
                alert.view.tintColor = UIView().tintColor
            })
        } else {
            let alert = UIAlertController(title: "Create tournament", message: "Type in a tournament name and choose tournament type. You can change this later at any time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            let publicCreate = UIAlertAction(title: "Public", style: UIAlertActionStyle.default, handler: { (action) in
                self.registerTournament(private: false, tournamentName: alert.textFields!.first!.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            })
            publicCreate.isEnabled = false
            alert.addAction(publicCreate)
            let privateCreate = UIAlertAction(title: "Private", style: UIAlertActionStyle.default, handler: { (action) in
                self.registerTournament(private: true, tournamentName: alert.textFields!.first!.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            })
            privateCreate.isEnabled = false
            alert.addAction(privateCreate)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Tournament name"
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                    publicCreate.isEnabled = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
                    privateCreate.isEnabled = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""
                }
            }
            
            self.present(alert, animated: true, completion: {
                alert.view.tintColor = UIView().tintColor
            })
        }
    }
    
    func registerTournament(private: Bool, tournamentName: String) {
        //...
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
        // Reset cell
        cell.adminIcon?.isHidden = true
        cell.tournamentName?.text = "--"
        cell.tournamentType?.text = "-- tournament"
        cell.tournamentStatus?.text = "Status: --"
        cell.tournamentDate?.text = "--"
        
        // Configure the cell...
        var tournament = [String: Any]()
        if indexPath.section == 0  {
            tournament = myTournaments[indexPath.row]
        } else {
            tournament = publicTournaments[indexPath.row]
        }
        
        cell.tournamentName?.text = tournament["tournamentName"] as? String
        
        if tournament["publicEnter"] as! Bool {
            cell.tournamentType?.text = "Public tournament"
        } else {
            cell.tournamentType?.text = "Private tournament"
        }
        
        if tournament["createdBy"] as? String == FIRAuth.auth()?.currentUser?.uid {
            cell.adminIcon?.isHidden = false
        }
        
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
