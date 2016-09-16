//
//  ExistingAppChecker.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import CloudKit
import Firebase

class ExistingAppChecker: NSObject {
    func checkIfAppSetup(viewController: UIViewController) {
        if let region = UserDefaults.standard.string(forKey: "league_region") {
            print("App Region: " + region)
        } else {
            promptUserForRegion(viewController: viewController, userChose: { (region) in
                UserDefaults.standard.setValue(region, forKey: "league_region")
                FIRMessaging.messaging().subscribe(toTopic: "/topics/" + region)
            })
        }
    }
    
    func promptUserForRegion(viewController: UIViewController, userChose: @escaping (region: String) -> Void) {
        let alert = UIAlertController(title: "Region Selector", message: "Select the League of Legends region for this app to use", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "North America", style: .default, handler: { (action) in
            userChose(region: "na")
        }))
        alert.addAction(UIAlertAction(title: "EU West", style: .default, handler: { (action) in
            userChose(region: "euw")
        }))
        alert.addAction(UIAlertAction(title: "EU Nordic & East", style: .default, handler: { (action) in
            userChose(region: "eune")
        }))
        alert.addAction(UIAlertAction(title: "Latin America North", style: .default, handler: { (action) in
            userChose(region: "lan")
        }))
        alert.addAction(UIAlertAction(title: "Latin America South", style: .default, handler: { (action) in
            userChose(region: "las")
        }))
        alert.addAction(UIAlertAction(title: "Brazil", style: .default, handler: { (action) in
            userChose(region: "br")
        }))
        alert.addAction(UIAlertAction(title: "Japan", style: .default, handler: { (action) in
            userChose(region: "jp")
        }))
        alert.addAction(UIAlertAction(title: "Russia", style: .default, handler: { (action) in
            userChose(region: "ru")
        }))
        alert.addAction(UIAlertAction(title: "Turkey", style: .default, handler: { (action) in
            userChose(region: "tr")
        }))
        alert.addAction(UIAlertAction(title: "Oceania", style: .default, handler: { (action) in
            userChose(region: "oce")
        }))
        /*alert.addAction(UIAlertAction(title: "Republic of Korea", style: .default, handler: { (action) in
         userChose(region: "kr")
         }))*/
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
