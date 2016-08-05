//
//  ServerStatus.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ServerStatus: UITableViewController, UIPopoverPresentationControllerDelegate {
    var services = [Service]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func imageWithColor(severity: String, index: IndexPath) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 10, height: self.tableView.rectForRow(at: index).size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        var imageColor = UIColor.white
        if severity == "info" {
            imageColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
        } else if severity == "warn" {
            imageColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1)
        } else if severity == "error" {
            imageColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        }
        context?.setFillColor(imageColor.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh() {
        self.refreshControl?.beginRefreshing()
        StatusEndpoint().getShardStatus(completion: { (shardStatus) in
            self.services = shardStatus.services
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, errorBlock: {
            self.refreshControl?.endRefreshing()
            // Error
        })
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return services[section].name + " - " + services[section].status
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services[section].incidents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incidentCell", for: indexPath)
        // Popover Size
        self.preferredContentSize = CGSize(width: 400, height: tableView.contentSize.height)
        // Configure the cell...
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
