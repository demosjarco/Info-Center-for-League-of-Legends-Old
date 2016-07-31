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
        checkIfUserEnabledIcloud(viewController: viewController)
    }
    
    func checkIfUserEnabledIcloud(viewController: UIViewController) {
        if (UserDefaults.standard.object(forKey: "league_useIcloud") == nil) {
            UserDefaults.standard.set(true, forKey: "league_useIcloud")
        }
        
        if UserDefaults.standard.bool(forKey: "league_useIcloud") {
            checkIfIcloudAvailable(viewController: viewController)
        } else {
            offlineMode(viewController: viewController)
        }
    }
    
    func checkIfIcloudAvailable(viewController: UIViewController) {
        CKContainer.default().accountStatus { (accountStatus, error) in
            switch accountStatus {
            case CKAccountStatus.couldNotDetermine:
                let alert = UIAlertController(title: "iCloud", message: "An error occurred when getting the account status. Please check your iCloud Settings. To do so, go to your home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.\n\nIf you do not want to use iCloud, go to your home screen, launch Settings, tap IC:LoL, and turn off the switch for iCloud.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                    self.offlineMode(viewController: viewController)
                }))
                break
            case CKAccountStatus.noAccount:
                let alert = UIAlertController(title: "iCloud", message: "No iCloud account detected. Please check your iCloud Settings. To do so, go to your home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.\n\nIf you do not want to use iCloud, go to your home screen, launch Settings, tap IC:LoL, and turn off the switch for iCloud.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                    self.offlineMode(viewController: viewController)
                }))
                break
            case CKAccountStatus.restricted:
                let alert = UIAlertController(title: "iCloud", message: "The current iCloud account has restrictions. Please check with the the person responsible or in charge of this device or account to change this setting.\n\nIf you do not want to use iCloud, go to your home screen, launch Settings, tap IC:LoL, and turn off the switch for iCloud.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                    self.offlineMode(viewController: viewController)
                }))
                break
            default:
                // All good
                self.onlineMode(viewController: viewController)
                break
            }
        }
    }
    
    func onlineMode(viewController: UIViewController) {
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: CKRecordID(recordName: "savedPreferences")) { (record, error) in
            if (error != nil) {
                // Not saved in iCloud
                if (UserDefaults.standard.object(forKey: "league_region") != nil) {
                    // Locally saved
                    
                    let regionRecord = CKRecord(recordType: "UserPreferences", recordID: CKRecordID(recordName: "savedPreferences"))
                    regionRecord["regionCode"] = UserDefaults.standard.string(forKey: "league_region")
                    CKContainer.default().privateCloudDatabase.save(regionRecord, completionHandler: { (savedRecord, saveError) in
                        if (saveError != nil) {
                            // Didn't save
                            print(String(saveError))
                        }
                    })
                } else {
                    // Doesn't exist local - ask user
                    self.promptUserForRegion(viewController: viewController, userChose: { (region) in
                        UserDefaults.standard.setValue(region, forKey: "league_region")
                        let regionRecord = CKRecord(recordType: "UserPreferences", recordID: CKRecordID(recordName: "savedPreferences"))
                        regionRecord["regionCode"] = region
                        CKContainer.default().privateCloudDatabase.save(regionRecord, completionHandler: { (savedRecord, saveError) in
                            if (saveError != nil) {
                                // Didn't save
                                print(String(saveError))
                            }
                        })
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/" + region)
                    })
                }
            } else {
                // Saved in iCloud
                let icloudRegion = record!["regionCode"] as! String
                // Check if local saved
                if (UserDefaults.standard.object(forKey: "league_region") != nil) {
                    // Locally saved
                    
                    // Check if conflict
                    if UserDefaults.standard.string(forKey: "league_region") != icloudRegion {
                        // Conflict
                        let alert = UIAlertController(title: "Region Conflict", message: "You have different region set on iCloud vs. on this device. Choose which one below you want to keep.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: icloudRegion, style: .default, handler: { (action) in
                            UserDefaults.standard.setValue(icloudRegion, forKey: "league_region")
                            // Already in iCloud
                            FIRMessaging.messaging().subscribe(toTopic: "/topics/" + icloudRegion)
                        }))
                        alert.addAction(UIAlertAction(title: UserDefaults.standard.string(forKey: "league_region"), style: .default, handler: { (action) in
                            // Already in NSUserDefaults
                            record!["regionCode"] = UserDefaults.standard.string(forKey: "league_region")
                            CKContainer.default().privateCloudDatabase.save(record!, completionHandler: { (savedRecord, saveError) in
                                if (saveError != nil) {
                                    // Didn't save
                                    print(String(saveError))
                                }
                            })
                            FIRMessaging.messaging().subscribe(toTopic: "/topics/" + icloudRegion)
                        }))
                    } else {
                        // Same
                        FIRMessaging.messaging().subscribe(toTopic: "/topics/" + icloudRegion)
                    }
                } else {
                    // Doesn't exist local - save cloud value as local
                    UserDefaults.standard.setValue(icloudRegion, forKey: "league_region")
                }
            }
        }
    }
    
    func offlineMode(viewController: UIViewController) {
        if let region = UserDefaults.standard.string(forKey: "league_region") {
            print("App Region: " + region)
        } else {
            promptUserForRegion(viewController: viewController, userChose: { (region) in
                UserDefaults.standard.setValue(region, forKey: "league_region")
                FIRMessaging.messaging().subscribe(toTopic: "/topics/" + region)
            })
        }
    }
    
    func promptUserForRegion(viewController: UIViewController, userChose: (region: String) -> Void) {
        autoreleasepool { ()
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
            
            viewController.present(alert, animated: true, completion: {
                // ...
            })
        }
    }
}
