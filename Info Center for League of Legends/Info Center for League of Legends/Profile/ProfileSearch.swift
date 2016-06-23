//
//  ProfileSearch.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ProfileSearch: MainTableViewController, UISearchBarDelegate {
    var recentSummoners:NSArray = [];
    var summonerInfoForSegue:NSDictionary = [:];
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ExistingAppChecker().checkIfAppSetup(viewController: self)

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refresh()
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        recentSummoners = PlistManager().loadRecentSummoners()
        autoreleasepool { ()
        }
        self.refreshControl?.endRefreshing()
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
