//
//  ProfileSearch.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

class ProfileSearch: MainTableViewController, UISearchBarDelegate {
    var recentSummoners = NSMutableArray()
    var summonerInfoForSegue = SummonerDto()

    override func viewDidLoad() {
        super.viewDidLoad()
        ExistingAppChecker().checkIfAppSetup(viewController: self)

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refresh()
    }
    
    @IBAction func refresh() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
            self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl!.frame.size.height)
        }, completion: nil)
        self.refreshControl?.beginRefreshing()
        recentSummoners = NSMutableArray()
        PlistManager().loadRecentSummoners { (recentSummonersLoaded) in
            for summonerId in recentSummonersLoaded as! [CLong] {
                autoreleasepool({ ()
                    let temp = SummonerDto()
                    temp.summonerId = summonerId
                    self.recentSummoners.add(temp)
                })
            }
            self.refreshControl?.endRefreshing()
            self.tableView.beginUpdates()
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // Limit to 16 characters
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = searchBar.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= 16
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        autoreleasepool { ()
            let loading = UIAlertController(title: "Loading...", message: "\n\n", preferredStyle: .alert)
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            indicator.color = UIColor.black()
            indicator.hidesWhenStopped = true
            indicator.center = CGPoint(x: 130.5, y: 65.5)
            indicator.startAnimating()
            
            loading.view.addSubview(indicator)
            self.present(loading, animated: true, completion: nil)
            
            SummonerEndpoint().getSummonersForSummonerNames(summonerNames: [searchBar.text!], completion: { (summonerMap) in
                self.summonerInfoForSegue = summonerMap.values.first!
                
                PlistManager().addToRecentSummoners(newSummoner: summonerMap.values.first!)
                self.recentSummoners.insert(summonerMap.values.first!, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: self.recentSummoners.index(of: summonerMap.values.first!), section: 0)], with: .automatic)
                
                indicator.stopAnimating()
                loading.dismiss(animated: true, completion: {
                    self.performSegue(withIdentifier: "showProfileInfo", sender: self)
                })
            }, notFound: {
                indicator.stopAnimating()
                loading.title = "Summoner doesn't exist"
                loading.message = "Please check your spelling and/or region"
                loading.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            }, errorBlock: {
                indicator.stopAnimating()
                loading.title = "Summoner lookup failed"
                loading.message = "Please check your connection and/or try again later. This problem has been submitted for review."
                loading.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentSummoners.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentProfileCell", for: indexPath)
        // Performance
        // Slow for now (as of iOS 10b3)
        // cell.layer.shouldRasterize = true
        // cell.layer.rasterizationScale = UIScreen.main().scale
        
        // Clear old values
        cell.imageView?.image = UIImage(named: "poroIcon")
        cell.textLabel?.text = "--"
        cell.detailTextLabel?.text = "--"
        
        autoreleasepool { ()
            var temp = recentSummoners[indexPath.row] as! SummonerDto
            
            SummonerEndpoint().getSummonersForIds(summonerIds: [temp.summonerId], completion: { (summonerMap) in
                self.recentSummoners.replaceObject(at: indexPath.row, with: summonerMap.values.first!)
                temp = summonerMap.values.first!
                
                cell.textLabel?.text = temp.name
                
                DDragon().getProfileIcon(profileIconId: temp.profileIconId, completion: { (profileIconURL) in
                    cell.imageView!.setImageWith(URLRequest(url: profileIconURL), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                        cell.imageView!.image = image
                        cell.setNeedsLayout()
                    }, failure: { (request, response, error) in
                        cell.imageView!.image = UIImage(named: "poroIcon")
                        cell.setNeedsLayout()
                    })
                })
                
                LeagueEndpoint().getLeagueEntryBySummonerIds(summonerIds: [temp.summonerId], completion: { (summonerMap) in
                    // Ranked
                    autoreleasepool({ ()
                        let currentSummoner = summonerMap.values.first
                        
                        var highestTier: Int = 7
                        var highestTierSpelledOut: String = ""
                        var highestDivision: Int = 6
                        var highestDivisionRoman: String = ""
                        
                        for league in currentSummoner! {
                            if highestTier > LeagueEndpoint().tierToNumber(tier: league.tier) {
                                highestTier = LeagueEndpoint().tierToNumber(tier: league.tier)
                                highestTierSpelledOut = league.tier
                                highestDivision = 6
                                
                                for entry in league.entries {
                                    if highestDivision > LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division) {
                                        highestDivision = LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division)
                                        highestDivisionRoman = entry.division
                                    }
                                }
                            } else if highestTier == LeagueEndpoint().tierToNumber(tier: league.tier) {
                                for entry in league.entries {
                                    if highestDivision > LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division) {
                                        highestDivision = LeagueEndpoint().romanNumeralToNumber(romanNumeral: entry.division)
                                        highestDivisionRoman = entry.division
                                    }
                                }
                            }
                            
                            if highestTier < 2 {
                                // Challenger & Master
                                // Dont use division
                                autoreleasepool { ()
                                    let tierIcon = NSTextAttachment()
                                    autoreleasepool { ()
                                        let pictureHeight = tableView.rectForRow(at: indexPath).size.height / 2
                                        
                                        UIGraphicsBeginImageContextWithOptions(CGSize(width: pictureHeight, height: pictureHeight), false, 1.0)
                                        UIImage(named: highestTierSpelledOut.lowercased())?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: pictureHeight, height: pictureHeight)))
                                        tierIcon.image = UIGraphicsGetImageFromCurrentImageContext()
                                        UIGraphicsEndImageContext()
                                    }
                                    
                                    let attString = NSMutableAttributedString(string: " " + highestTierSpelledOut.capitalized)
                                    attString.addAttribute(NSBaselineOffsetAttributeName, value: tableView.rectForRow(at: indexPath).size.height / 4 - UIFont.preferredFont(forTextStyle: UIFontTextStyleFootnote).capHeight / 2, range: NSMakeRange(1, attString.length - 1))
                                    attString.replaceCharacters(in: NSMakeRange(0, 1), with: AttributedString(attachment: tierIcon))
                                    cell.detailTextLabel?.attributedText = attString
                                    cell.detailTextLabel?.setNeedsLayout()
                                    cell.setNeedsLayout()
                                }
                            } else {
                                // Diamond and lower
                                // Use division
                                autoreleasepool { ()
                                    let tierIcon = NSTextAttachment()
                                    autoreleasepool { ()
                                        let pictureHeight = tableView.rectForRow(at: indexPath).size.height / 2
                                        
                                        UIGraphicsBeginImageContextWithOptions(CGSize(width: pictureHeight, height: pictureHeight), false, 1.0)
                                        UIImage(named: highestTierSpelledOut.lowercased() + "_" + highestDivisionRoman.lowercased())?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: pictureHeight, height: pictureHeight)))
                                        tierIcon.image = UIGraphicsGetImageFromCurrentImageContext()
                                        UIGraphicsEndImageContext()
                                    }
                                    
                                    let attString = NSMutableAttributedString(string: " " + highestTierSpelledOut.capitalized + " " + highestDivisionRoman.uppercased())
                                    attString.addAttribute(NSBaselineOffsetAttributeName, value: tableView.rectForRow(at: indexPath).size.height / 4 - UIFont.preferredFont(forTextStyle: UIFontTextStyleFootnote).capHeight / 2, range: NSMakeRange(1, attString.length - 1))
                                    attString.replaceCharacters(in: NSMakeRange(0, 1), with: AttributedString(attachment: tierIcon))
                                    cell.detailTextLabel?.attributedText = attString
                                    cell.detailTextLabel?.setNeedsLayout()
                                    cell.setNeedsLayout()
                                }
                            }
                        }
                    })
                }, notFound: {
                    // Unranked
                    autoreleasepool { ()
                        let tierIcon = NSTextAttachment()
                        autoreleasepool { ()
                            let pictureHeight = tableView.rectForRow(at: indexPath).size.height / 2
                            
                            UIGraphicsBeginImageContextWithOptions(CGSize(width: pictureHeight, height: pictureHeight), false, 1.0)
                            UIImage(named: "provisional")?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: pictureHeight, height: pictureHeight)))
                            tierIcon.image = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                        }
                        
                        let attString = NSMutableAttributedString(string: " Level " + String(temp.summonerLevel))
                        attString.addAttribute(NSBaselineOffsetAttributeName, value: tableView.rectForRow(at: indexPath).size.height / 4 - UIFont.preferredFont(forTextStyle: UIFontTextStyleFootnote).capHeight / 2, range: NSMakeRange(1, attString.length - 1))
                        attString.replaceCharacters(in: NSMakeRange(0, 1), with: AttributedString(attachment: tierIcon))
                        cell.detailTextLabel?.attributedText = attString
                        cell.detailTextLabel?.setNeedsLayout()
                        cell.setNeedsLayout()
                    }
                }, errorBlock: {
                    // Error
                    autoreleasepool { ()
                        let tierIcon = NSTextAttachment()
                        autoreleasepool { ()
                            let pictureHeight = tableView.rectForRow(at: indexPath).size.height / 2
                            
                            UIGraphicsBeginImageContextWithOptions(CGSize(width: pictureHeight, height: pictureHeight), false, 1.0)
                            UIImage(named: "provisional")?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: pictureHeight, height: pictureHeight)))
                            tierIcon.image = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                        }
                        
                        let attString = NSMutableAttributedString(string: " Level " + String(temp.summonerLevel))
                        attString.addAttribute(NSBaselineOffsetAttributeName, value: tableView.rectForRow(at: indexPath).size.height / 4 - UIFont.preferredFont(forTextStyle: UIFontTextStyleFootnote).capHeight / 2, range: NSMakeRange(1, attString.length - 1))
                        attString.replaceCharacters(in: NSMakeRange(0, 1), with: AttributedString(attachment: tierIcon))
                        cell.detailTextLabel?.attributedText = attString
                        cell.detailTextLabel?.setNeedsLayout()
                        cell.setNeedsLayout()
                    }
                })
            }, errorBlock: {
                    
            })
        }
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.summonerInfoForSegue = recentSummoners[indexPath.row] as! SummonerDto
        return indexPath
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
            recentSummoners.removeObject(at: indexPath.row)
            PlistManager().removeItemInRecentSummoners(oldIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = recentSummoners.object(at: sourceIndexPath.row)
        recentSummoners.removeObject(at: sourceIndexPath.row)
        recentSummoners.insert(item, at: destinationIndexPath.row)
        
        PlistManager().moveItemInRecentSummoners(oldIndex: sourceIndexPath.row, newIndex: destinationIndexPath.row)
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
        if segue.identifier == "showProfileInfo" {
            let profileView = segue.destinationViewController as! ProfileView
            profileView.summoner = self.summonerInfoForSegue
        }
    }
}
