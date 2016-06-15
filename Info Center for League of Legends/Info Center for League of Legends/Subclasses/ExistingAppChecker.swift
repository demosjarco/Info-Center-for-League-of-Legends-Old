//
//  ExistingAppChecker.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase

class ExistingAppChecker: NSObject {
    func checkIfAppSetup(viewController: UIViewController) {
        checkRegion(viewController: viewController)
    }
    
    func checkRegion(viewController: UIViewController) {
        autoreleasepool {
            let prefs = UserDefaults.standard()
            
            if let region = prefs.string(forKey: "league_region") {
                print("App Region: " + region)
            } else {
                autoreleasepool {
                    let alert = UIAlertController(title: "Region Selector", message: "Select the League of Legends region for this app to use", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "North America", style: .default) { (action) in
                        prefs.setValue("na", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/na")
                    })
                    alert.addAction(UIAlertAction(title: "EU West", style: .default) { (action) in
                        prefs.setValue("euw", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/euw")
                    })
                    alert.addAction(UIAlertAction(title: "EU Nordic & East", style: .default) { (action) in
                        prefs.setValue("eune", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/eune")
                    })
                    alert.addAction(UIAlertAction(title: "Latin America North", style: .default) { (action) in
                        prefs.setValue("lan", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/lan")
                    })
                    alert.addAction(UIAlertAction(title: "Latin America South", style: .default) { (action) in
                        prefs.setValue("las", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/las")
                    })
                    alert.addAction(UIAlertAction(title: "Brazil", style: .default) { (action) in
                        prefs.setValue("br", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/br")
                    })
                    alert.addAction(UIAlertAction(title: "Japan", style: .default) { (action) in
                        prefs.setValue("jp", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/jp")
                    })
                    alert.addAction(UIAlertAction(title: "Russia", style: .default) { (action) in
                        prefs.setValue("ru", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/na")
                    })
                    alert.addAction(UIAlertAction(title: "Turkey", style: .default) { (action) in
                        prefs.setValue("na", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/ru")
                    })
                    alert.addAction(UIAlertAction(title: "Oceania", style: .default) { (action) in
                        prefs.setValue("oce", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/oce")
                    })
                    alert.addAction(UIAlertAction(title: "Republic of Korea", style: .default) { (action) in
                        prefs.setValue("kr", forKey: "league_region")
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/kr")
                    })
                    
                    viewController.present(alert, animated: true) {
                        // ...
                    }
                }
            }
        }
    }
}
