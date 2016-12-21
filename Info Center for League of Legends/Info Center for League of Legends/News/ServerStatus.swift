//
//  ServerStatus.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import JSBadgeView

class ServerStatus: UITableViewController, UIPopoverPresentationControllerDelegate {
    var services = [Service]()
    var lastRefreshTime = Date()
    var refreshTimeText = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.popoverPresentationController?.delegate = self
        refreshTimeText = self.toolbarItems![1]
        
        refresh()
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        // Shown in popover
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.popoverPresentationController?.backgroundColor = self.tableView.backgroundColor
    }
    
    func imageWithColor(_ severity: String, index: IndexPath) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 13, height: self.tableView.rectForRow(at: index).size.height)
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
        refreshTimeText.title = "Loading..."
        self.refreshControl?.beginRefreshing()
        StatusEndpoint().getShardStatus({ (shardStatus) in
            self.title = shardStatus.name + " Status"
            self.services = shardStatus.services
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.lastRefreshTime = Date()
            self.refreshTimeText.title = "Refreshing in " + String(60 - Int(floor(self.lastRefreshTime.timeIntervalSinceNow) * -1)) + " seconds..."
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshWithTimer(_:)), userInfo: nil, repeats: false)
        }, errorBlock: {
            self.refreshTimeText.title = "Error...trying again in 60 seconds..."
            self.refreshControl?.endRefreshing()
            self.lastRefreshTime = Date()
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshWithTimer(_:)), userInfo: nil, repeats: false)
            // Error
        })
    }
    
    func refreshWithTimer(_ timer: Timer?) {
        timer?.invalidate()
        refreshTimeText.title = "Refreshing in " + String(60 - Int(floor(lastRefreshTime.timeIntervalSinceNow) * -1)) + " seconds..."
        if lastRefreshTime.timeIntervalSinceNow <= -60.0 {
            refresh()
        } else {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshWithTimer(_:)), userInfo: nil, repeats: false)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Popover Size
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        
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
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        // Configure the cell...
        let incident = services[indexPath.section].incidents[indexPath.row]
        
        let severityImage = UIImageView(image: imageWithColor(incident.updates.first!.severity, index: indexPath))
        cell.contentView.addSubview(severityImage)
        let badgeView = JSBadgeView(parentView: severityImage, alignment: .center)
        badgeView?.badgeBackgroundColor = UIColor.clear
        badgeView?.badgeText = String(incident.updates.count)
        
        cell.detailTextLabel?.text = incident.updates.first?.content
        for translation in incident.updates.first!.translations {
            if translation.locale == Locale.autoupdatingCurrent.identifier {
                cell.detailTextLabel?.text = translation.content
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: incident.updates.first!.updated_at)
        if incident.updates.first?.author == "" {
            cell.textLabel?.text = "Network Operations - " + dateString
        } else {
            cell.textLabel?.text = incident.updates.first!.author + " - " + dateString
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showStatusUpdates" {
            let detail = segue.destination as! StatusDetail
            detail.serviceSlug = services[self.tableView.indexPathForSelectedRow!.section].slug
            detail.incidentId = services[self.tableView.indexPathForSelectedRow!.section].incidents[self.tableView.indexPathForSelectedRow!.row].incidentId
        }
    }
}
