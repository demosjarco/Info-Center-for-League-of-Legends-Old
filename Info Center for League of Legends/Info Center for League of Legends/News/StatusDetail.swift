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
        
        //refreshTimeText = self.toolbarItems![1]
        
        refresh()
    }
    
    @IBAction func refresh() {
        refreshTimeText.title = "Loading..."
        self.refreshControl?.beginRefreshing()
        StatusEndpoint().getShardStatus(completion: { (shardStatus) in
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
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshWithTimer(timer:)), userInfo: nil, repeats: false)
            }, errorBlock: {
                self.refreshTimeText.title = "Error...trying again in 60 seconds..."
                self.refreshControl?.endRefreshing()
                self.lastRefreshTime = Date()
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshWithTimer(timer:)), userInfo: nil, repeats: false)
                // Error
        })
    }
    
    func refreshWithTimer(timer: Timer?) {
        timer?.invalidate()
        refreshTimeText.title = "Refreshing in " + String(60 - Int(floor(lastRefreshTime.timeIntervalSinceNow) * -1)) + " seconds..."
        if lastRefreshTime.timeIntervalSinceNow <= -60.0 {
            refresh()
        } else {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.refreshWithTimer(timer:)), userInfo: nil, repeats: false)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: updates[section].updated_at)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
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
        // Configure the cell...
        cell.backgroundColor = UIColor.red

        return cell
    }
}
