//
//  ProfileSearch.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

class ProfileSearch: MainTableViewController, UISearchBarDelegate {
    var recentSummoners:NSArray = []
    var summonerInfoForSegue = SummonerDto()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ExistingAppChecker().checkIfAppSetup(viewController: self)

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refresh()
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        recentSummoners = PlistManager().loadRecentSummoners()
        self.refreshControl?.endRefreshing()
        self.tableView.beginUpdates()
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        self.tableView.endUpdates()
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
                
                self.refresh()
                
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
        return recentSummoners.count
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
