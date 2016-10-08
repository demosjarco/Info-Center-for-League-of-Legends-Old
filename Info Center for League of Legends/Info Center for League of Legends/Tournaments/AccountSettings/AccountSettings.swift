//
//  AccountSettings.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 10/7/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase

class AccountSettings: UITableViewController, UITextFieldDelegate {
    var currentUserProfileName = ""
    var linkedSummoners = [[String: AnyObject]]()
    
    func randomAlphaNumericString(length: Int) -> String {
        
        //let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
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
        
        print("RANDOM STRING: " + randomAlphaNumericString(length: 5))
        
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("profileName").observeSingleEvent(of: .value, with: { (snapshot) in
            self.currentUserProfileName = snapshot.value as! String
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        })
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").observe(.childAdded, with: { (snapshot) in
            self.linkedSummoners.append(snapshot.value as! [String: AnyObject])
            let tempArray = self.linkedSummoners as NSArray
            self.tableView.insertRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 1)], with: .automatic)
        })
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").observe(.childChanged, with: { (snapshot) in
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
        FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").observe(.childRemoved, with: { (snapshot) in
            let tempArray = self.linkedSummoners as NSArray
            self.linkedSummoners.remove(at: tempArray.index(of: snapshot.value as! [String: AnyObject]))
            self.tableView.deleteRows(at: [IndexPath(row: tempArray.index(of: snapshot.value as! [String: AnyObject]), section: 1)], with: .automatic)
        })
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
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Linked Summoners"
        } else {
            return nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return linkedSummoners.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileNameCell", for: indexPath) as! AccountNameCell
            // Configure the cell...
            cell.accountNameLabel?.text = "Profile Name"
            cell.accountNameField?.text = self.currentUserProfileName
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "summonerIdLinkCell", for: indexPath)
            // Configure the cell...
            SummonerEndpoint().getSummonersForIds(summonerIds: [linkedSummoners[indexPath.row]["summonerId"] as! CLong], completion: { (summonerMap) in
                cell.textLabel?.text = summonerMap.values.first?.name
                if self.linkedSummoners[indexPath.row]["verified"] as! Bool {
                    cell.detailTextLabel?.text = "Verified"
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
        SummonerEndpoint().getMasteriesForSummonerIds(summonerIds: [linkedSummoners[indexPath.row]["summonerId"] as! CLong], completion: { (summonerMap) in
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
