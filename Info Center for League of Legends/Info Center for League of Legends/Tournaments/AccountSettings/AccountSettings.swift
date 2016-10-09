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
    var oldUser:FIRUser
    var currentUserProfileName = ""
    var linkedSummoners = [[String: AnyObject]]()
    
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
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
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
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let unlinkAction = UITableViewRowAction(style: .destructive, title: "Unlink") { (action, actionIndexPath) in
            FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid).child("summonerIds").child(String(self.linkedSummoners[actionIndexPath.row]["summonerId"] as! CLong)).removeValue()
        }
        return [unlinkAction]
    }
}
