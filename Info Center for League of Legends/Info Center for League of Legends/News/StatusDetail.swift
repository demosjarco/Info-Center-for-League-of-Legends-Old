//
//  StatusDetail.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class StatusDetail: UITableViewController {
    var serviceSlug:String = ""
    var incidentId:CLong = 0
    
    var updates = [Message]()
    var lastRefreshTime = Date()
    var refreshTimeText = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTimeText = self.toolbarItems![1]
        
        refresh()
    }
    
    @IBAction func refresh() {
        refreshTimeText.title = "Loading..."
        self.refreshControl?.beginRefreshing()
        StatusEndpoint().getShardStatus({ (shardStatus) in
            for service in shardStatus.services {
                if service.slug == self.serviceSlug {
                    for incident in service.incidents {
                        if incident.incidentId == self.incidentId {
                            self.updates = incident.updates
                        }
                    }
                }
            }
            if self.updates.count == 0 {
                // Incident gone
                self.navigationController?.popViewController(animated: true)
            }
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        if updates[section].author == "" {
            return "Network Operations - " + dateFormatter.string(from: updates[section].updated_at)
        } else {
            return updates[section].author + " - " + dateFormatter.string(from: updates[section].updated_at)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // Popover Size
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        
        var content = updates[section].content
        for translation in updates[section].translations {
            if translation.locale == Locale.autoupdatingCurrent.identifier {
                content = translation.content
            }
        }
        return content
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return updates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "severityCell", for: indexPath)
        // Popover Size
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: tableView.contentSize.height)
        // Configure the cell...
        switch updates[indexPath.section].severity {
        case "info":
            cell.backgroundColor = UIColor(red: 0, green: 0, blue: 1.0/3.0, alpha: 1)
        case "warn":
            cell.backgroundColor = UIColor(red: 1.0/3.0, green: 1.0/3.0, blue: 0, alpha: 1)
        case "error":
            cell.backgroundColor = UIColor(red: 1.0/3.0, green: 0, blue: 0, alpha: 1)
        default:
            cell.backgroundColor = UIColor.white
        }

        return cell
    }
}
