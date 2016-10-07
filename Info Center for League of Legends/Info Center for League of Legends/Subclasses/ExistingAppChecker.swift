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
    
    func promptUserForRegion(viewController: UIViewController, userChose: @escaping (_ region: String) -> Void) {
        let alert = UIAlertController(title: "Region Selector", message: "Select the League of Legends region for this app to use", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "North America", style: .default, handler: { (action) in
            userChose("na")
        }))
        alert.addAction(UIAlertAction(title: "EU West", style: .default, handler: { (action) in
            userChose("euw")
        }))
        alert.addAction(UIAlertAction(title: "EU Nordic & East", style: .default, handler: { (action) in
            userChose("eune")
        }))
        alert.addAction(UIAlertAction(title: "Latin America North", style: .default, handler: { (action) in
            userChose("lan")
        }))
        alert.addAction(UIAlertAction(title: "Latin America South", style: .default, handler: { (action) in
            userChose("las")
        }))
        alert.addAction(UIAlertAction(title: "Brazil", style: .default, handler: { (action) in
            userChose("br")
        }))
        alert.addAction(UIAlertAction(title: "Japan", style: .default, handler: { (action) in
            userChose("jp")
        }))
        alert.addAction(UIAlertAction(title: "Russia", style: .default, handler: { (action) in
            userChose("ru")
        }))
        alert.addAction(UIAlertAction(title: "Turkey", style: .default, handler: { (action) in
            userChose("tr")
        }))
        alert.addAction(UIAlertAction(title: "Oceania", style: .default, handler: { (action) in
            userChose("oce")
        }))
        /*alert.addAction(UIAlertAction(title: "Republic of Korea", style: .default, handler: { (action) in
         userChose("kr")
         }))*/
        
        viewController.present(alert, animated: true) { 
            alert.view.tintColor = UIView().tintColor
        }
    }
}
