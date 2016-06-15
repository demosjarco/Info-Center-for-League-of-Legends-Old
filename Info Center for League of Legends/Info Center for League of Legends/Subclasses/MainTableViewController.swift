//
//  MainTableViewController.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase

class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableBG = UIView(frame: self.tableView.frame)
        tableBG.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        autoreleasepool {
            let bgImage = UIImageView(frame: tableBG.frame)
            bgImage.autoresizingMask = tableBG.autoresizingMask
            tableBG.addSubview(bgImage)
            
            let remoteConfig = FIRRemoteConfig.remoteConfig()
            remoteConfig.fetch(completionHandler: { (status, error) in
                let contentSeason = remoteConfig.configValue(forKey: "contentSeason")
                switch contentSeason {
                case 0:
                    // Snowdown
                    bgImage.image = UIImage(named: "howlingAbyss")
                    break
                case 0:
                    // Normal
                    bgImage.image = UIImage(named: "summonersRift")
                    break
                case 0:
                    // Harrowing
                    bgImage.image = UIImage(named: "shadowIsles")
                    break
                case 3:
                    // URF
                    bgImage.image = UIImage(named: "")
                    break
                default:
                    break
                }
                
                bgImage.contentMode = .scaleAspectFill
                
            })
            
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            tableBG.insertSubview(blur, aboveSubview: bgImage)
            blur.frame = tableBG.frame
            blur.autoresizingMask = tableBG.autoresizingMask
        }
        
        self.tableView.backgroundView = tableBG
    }
}
