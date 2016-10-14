//
//  AccountSettings.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 10/7/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class AccountSettings: UITableViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, FIRAuthUIDelegate {
    var oldUser = FIRAuth.auth()!.currentUser
    var currentUserProfileName = ""
    var linkedSummoners = [[String: AnyObject]]()
    var summonerAddedRef = FIRDatabase.database().reference()
    var summonerChangedRef = FIRDatabase.database().reference()
    var summonerRemovedRef = FIRDatabase.database().reference()
    
    func randomAlphaNumericString(length: Int) -> String {
//        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedChars = "0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.popoverPresentationController?.delegate = self
        
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("profileName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentUserProfileName = snapshot.value as! String
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        })
        
        observeSummonersForChanges()
    }
    
    func observeSummonersForChanges() {
        summonerAddedRef = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds")
        summonerAddedRef.observe(.childAdded, with: { (snapshot) in
            self.linkedSummoners.append(snapshot.value as! [String: AnyObject])
            let tempArray = self.linkedSummoners as NSArray
            self.tableView.insertRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 1)], with: .automatic)
        })
        summonerChangedRef = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds")
        summonerChangedRef.observe(.childChanged, with: { (snapshot) in
            let tempSummoner = snapshot.value as! [String: AnyObject]
            var index = 0
            for summoner in self.linkedSummoners {
                if summoner["summonerId"] as! CLong == tempSummoner["summonerId"] as! CLong {
                    break
                } else {
                    index += 1
                }
            }
            self.linkedSummoners[index] = snapshot.value as! [String: AnyObject]
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
        })
        summonerRemovedRef = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds")
        summonerRemovedRef.observe(.childRemoved, with: { (snapshot) in
            let tempArray = self.linkedSummoners as NSArray
            self.linkedSummoners.remove(at: tempArray.index(of: snapshot.value as! [String: AnyObject]))
            self.tableView.deleteRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 1)], with: .automatic)
        })
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        // Shown in popover
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.popoverPresentationController?.backgroundColor = self.tableView.backgroundColor
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func linkNewSummonerButton() {
        let randomCode = randomAlphaNumericString(length: 5)
        
        let alert = UIAlertController(title: "Link Summoner", message: "Type in summoner name to begin the link process. Afterwards change the name of one of your mastery pages to \"" + randomCode + "\" and tap on the name below to verify.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        let searchAction = UIAlertAction(title: "Search", style: UIAlertActionStyle.default, handler: { (action) in
            let summonerTextField = alert.textFields!.first! as UITextField
            SummonerEndpoint().getSummonersForSummonerNames(summonerNames: [summonerTextField.text!], completion: { (summonerMap) in
                let summoner = summonerMap.values.first!
                FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").updateChildValues([String(summoner.summonerId): ["summonerId": summoner.summonerId, "verified": false, "verifyCode": NSNumber(value: Int(randomCode)!)]])
            }, notFound: {
                let alert2 = UIAlertController(title: "Not found", message: "Please check your spelling and/or region", preferredStyle: UIAlertControllerStyle.alert)
                alert2.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert2, animated: true) {
                    alert2.view.tintColor = UIView().tintColor
                }
            }, errorBlock: {
                let alert3 = UIAlertController(title: "Summoner lookup failed", message: "Please check your connection and/or try again later. This problem has been submitted for review.", preferredStyle: UIAlertControllerStyle.alert)
                alert3.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert3, animated: true) {
                    alert3.view.tintColor = UIView().tintColor
                }
            })
        })
        searchAction.isEnabled = false
        alert.addAction(searchAction)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Summoner Name"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                searchAction.isEnabled = textField.text != ""
            }
        }
        
        self.present(alert, animated: true) { 
            alert.view.tintColor = UIView().tintColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func finishedChangingName(sender: UITextField) {
        if currentUserProfileName != "" && currentUserProfileName != "Loading..." {
            var userProfileName = ""
            if sender.text != nil {
                userProfileName = sender.text!
            }
            if userProfileName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                userProfileName = "Anonymous"
            }
            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["profileName": userProfileName.trimmingCharacters(in: .whitespacesAndNewlines)])
            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
            changeRequest?.displayName = userProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
            changeRequest?.commitChanges(completion: nil)
        }
    }
    
    func authUI(_ authUI: FIRAuthUI, didSignInWith user: FIRUser?, error: Error?) {
        if error == nil && user != nil {
            // Reload account type
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0 )], with: .automatic)
            
            // Remove old observers
            summonerAddedRef.removeAllObservers()
            summonerChangedRef.removeAllObservers()
            summonerRemovedRef.removeAllObservers()
            
            // Clear old table
            linkedSummoners = [[String: AnyObject]]()
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            
            // Re-observe from new account
            observeSummonersForChanges()
            
            FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                // Check if old user was anonymous account
                if self.oldUser!.isAnonymous {
                    // Old user was anonymous
                    // proceed to copy data to new user and delete old
                    let oldUserUid = self.oldUser!.uid
                    
                    // Check if user exists in database and old user was anonymous account
                    if !snapshot.hasChild(user!.uid) {
                        // Update all tournament uids to new one
                        FIRDatabase.database().reference().child("tournaments").observeSingleEvent(of: .value, with: { (snapshot2) in
                            let tournaments = snapshot2.value as! [String: [String: AnyObject]]
                            for tournamentId in tournaments.keys {
                                let tournamentSnapshot = snapshot2.childSnapshot(forPath: tournamentId)
                                let tournament = tournamentSnapshot.value as! [String: AnyObject]
                                
                                if tournamentSnapshot.hasChild("chat") {
                                    let chat = tournament["chat"] as! [String: [String: AnyObject]]
                                    for messageId in chat.keys {
                                        let messageSnapshot = tournamentSnapshot.childSnapshot(forPath: "chat").childSnapshot(forPath: messageId)
                                        let message = messageSnapshot.value as! [String: AnyObject]
                                        
                                        if message["userId"] as! String == oldUserUid {
                                            messageSnapshot.ref.updateChildValues(["userId" : user!.uid])
                                        }
                                    }
                                }
                                
                                let participants = tournament["participants"]! as! [String: [String: [String: AnyObject]]]
                                if tournamentSnapshot.childSnapshot(forPath: "participants").hasChild("pending") {
                                    let pending = participants["pending"]!
                                    for playerId in pending.keys {
                                        let playerSnapshot = tournamentSnapshot.childSnapshot(forPath: "participants").childSnapshot(forPath: "pending").childSnapshot(forPath: playerId)
                                        let player = playerSnapshot.value as! [String: AnyObject]
                                        if player["userId"] as! String == oldUserUid {
                                            playerSnapshot.ref.updateChildValues(["userId" : user!.uid])
                                        }
                                    }
                                }
                                
                                let teams = participants["teams"]!
                                for teamId in teams.keys {
                                    let playersSnapshot = tournamentSnapshot.childSnapshot(forPath: "participants").childSnapshot(forPath: "teams").childSnapshot(forPath: teamId).childSnapshot(forPath: "players")
                                    let players = playersSnapshot.value as! [String: [String: AnyObject]]
                                    for playerId in players.keys {
                                        let playerSnapshot = playersSnapshot.childSnapshot(forPath: playerId)
                                        let player = playerSnapshot.value as! [String: AnyObject]
                                        if playerSnapshot.hasChild("userId") {
                                            if player["userId"] as! String == oldUserUid {
                                                playerSnapshot.ref.updateChildValues(["userId" : user!.uid])
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Transfer old user data
                            let oldUserSnapshot = snapshot.childSnapshot(forPath: self.oldUser!.uid)
                            FIRDatabase.database().reference().child("users").child(user!.uid).updateChildValues(oldUserSnapshot.value as! [String : AnyObject], withCompletionBlock: { (error, ref) in
                                // Update name
                                FIRDatabase.database().reference().child("users").child(user!.uid).updateChildValues(["profileName" : user!.displayName!], withCompletionBlock: { (error2, ref2) in
                                    if error2 == nil {
                                        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("profileName").observeSingleEvent(of: .value, with: { (snapshot) in
                                            self.currentUserProfileName = snapshot.value as! String
                                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                        })
                                    }
                                })
                                
                                // Delete old user
                                self.oldUser?.delete(completion: { (error3) in
                                    if error3 == nil {
                                        FIRDatabase.database().reference().child("users").child(oldUserUid).removeValue()
                                    }
                                })
                            })
                        })
                    } else {
                        // new user data exists
                        
                        // Refresh name
                        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("profileName").observeSingleEvent(of: .value, with: { (snapshot) in
                            self.currentUserProfileName = snapshot.value as! String
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        })
                        
                        // Delete old anonymous user
                        self.oldUser?.delete(completion: { (error3) in
                            if error3 == nil {
                                FIRDatabase.database().reference().child("users").child(oldUserUid).removeValue()
                            }
                        })
                    }
                } else {
                    // Old user wasn't anonymous
                    // Don't delete old user
                    
                    // Check if new user exists in database
                    if !snapshot.hasChild(user!.uid) {
                        // Create new user
                        FIRDatabase.database().reference().child("users").child(user!.uid).updateChildValues(["profileName": user!.displayName!])
                        self.currentUserProfileName = user!.displayName!
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    } else {
                        // New user has data in database
                        // Leave alone
                        
                        // Refresh name
                        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("profileName").observeSingleEvent(of: .value, with: { (snapshot) in
                            self.currentUserProfileName = snapshot.value as! String
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        })
                    }
                }
            })
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Popover Size
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        
        if section == 0 {
            return nil
        } else {
            return "Linked Summoners"
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // Popover Size
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        
        if section == 0 {
            return "Tap on account type row to login or upgrade to a registered account. Anonymous accounts are lost on app deletion. In order to create a tournament you must have a registered account."
        } else {
            return "Click on the + above to link a League of Legends account to your account in order to create or join tournaments. There is a verification process by temporarily renaming a mastery page in order to verify that really is your account."
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return linkedSummoners.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Popover Size
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "profileNameCell", for: indexPath) as! AccountNameCell
                // Configure the cell...
                cell.accountNameLabel?.text = "Profile Name"
                cell.accountNameField?.text = self.currentUserProfileName
                cell.selectionStyle = .none
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "profileTypeCell", for: indexPath)
                // Configure the cell...
                cell.textLabel?.text = "Account type"
                cell.detailTextLabel?.text = FIRAuth.auth()!.currentUser!.isAnonymous ? "Anonymous" : "Registered"
                cell.selectionStyle = .gray
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "summonerIdLinkCell", for: indexPath)
            // Configure the cell...
            SummonerEndpoint().getSummonersForIds(summonerIds: [linkedSummoners[indexPath.row]["summonerId"] as! CLong], completion: { (summonerMap) in
                cell.textLabel?.text = summonerMap.values.first?.name
                if self.linkedSummoners[indexPath.row]["verified"] as! Bool {
                    cell.detailTextLabel?.text = nil
                    cell.selectionStyle = .none
                } else {
                    cell.detailTextLabel?.text = "Please rename a mastery page to \"" + String(self.linkedSummoners[indexPath.row]["verifyCode"] as! Int) + "\" and tap here."
                    cell.selectionStyle = .gray
                }
            }, errorBlock: {
            })
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                oldUser = FIRAuth.auth()!.currentUser!
                let authUI = FIRAuthUI.default()
                authUI?.delegate = self
                let authViewController = authUI?.authViewController()
                authViewController?.modalPresentationStyle = UIModalPresentationStyle.formSheet
                self.present(authViewController!, animated: true, completion: {
                    tableView.deselectRow(at: indexPath, animated: true)
                })
            }
        } else {
            if linkedSummoners[indexPath.row]["verified"] as! Bool {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                SummonerEndpoint().getMasteriesForSummonerIds(summonerIds: [self.linkedSummoners[indexPath.row]["summonerId"] as! CLong], completion: { (summonerMap) in
                    for masteryPage in summonerMap.values.first!.pages {
                        if masteryPage.name == String(self.linkedSummoners[indexPath.row]["verifyCode"] as! Int) {
                            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").child(String(summonerMap.values.first!.summonerId)).updateChildValues(["verified": true])
                            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").child(String(summonerMap.values.first!.summonerId)).child("verifyCode").removeValue()
                        }
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                }, errorBlock: {
                    tableView.deselectRow(at: indexPath, animated: true)
                })
            }
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let unlinkAction = UITableViewRowAction(style: .destructive, title: "Unlink") { (action, actionIndexPath) in
            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").child(String(self.linkedSummoners[actionIndexPath.row]["summonerId"] as! CLong)).removeValue()
        }
        return [unlinkAction]
    }
}
