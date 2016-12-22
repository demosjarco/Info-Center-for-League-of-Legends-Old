//
//  MainTableViewController.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class MainTableViewController: UITableViewController, GADBannerViewDelegate, GADAdSizeDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableBG = UIView(frame: self.tableView.frame)
        tableBG.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let bgImage = UIImageView(frame: tableBG.frame)
        tableBG.addSubview(bgImage)
        bgImage.autoresizingMask = tableBG.autoresizingMask
        bgImage.contentMode = .scaleAspectFill
        
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch(completionHandler: { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                
                remoteConfig["appBackground"].stringValue!
                
                let storage = FIRStorage.storage()
            }
        })
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        tableBG.insertSubview(blur, aboveSubview: bgImage)
        blur.frame = tableBG.frame
        blur.autoresizingMask = tableBG.autoresizingMask
        
        self.tableView.backgroundView = tableBG
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: self.tableView.contentInset.left, bottom: bannerView.adSize.size.height, right: self.tableView.contentInset.right)
        
        var tabBarHeight = CGFloat(0)
        if (self.tabBarController?.tabBar) != nil {
            tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        }
        let adFrame = self.tableView.tableFooterView?.frame
        let newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - tabBarHeight - adFrame!.size.height
        let newAdFrame = CGRect(x: adFrame!.origin.x, y: newOriginY, width: adFrame!.size.width, height: bannerView.adSize.size.height)
        self.tableView.tableFooterView?.frame = newAdFrame
    }
    
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        self.tableView.contentInset = UIEdgeInsets(top: self.tableView.contentInset.top, left: self.tableView.contentInset.left, bottom: size.size.height, right: self.tableView.contentInset.right)
        
        var tabBarHeight = CGFloat(0)
        if (self.tabBarController?.tabBar) != nil {
            tabBarHeight = self.tabBarController!.tabBar.frame.size.height
        }
        let adFrame = self.tableView.tableFooterView?.frame
        let newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - tabBarHeight - adFrame!.size.height
        let newAdFrame = CGRect(x: adFrame!.origin.x, y: newOriginY, width: adFrame!.size.width, height: bannerView.adSize.size.height)
        self.tableView.tableFooterView?.frame = newAdFrame
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.tableFooterView != nil {
            var tabBarHeight = CGFloat(0)
            if (self.tabBarController?.tabBar) != nil {
                tabBarHeight = self.tabBarController!.tabBar.frame.size.height
            }
            let adFrame = self.tableView.tableFooterView?.frame
            let newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - tabBarHeight - adFrame!.size.height
            let newAdFrame = CGRect(x: adFrame!.origin.x, y: newOriginY, width: adFrame!.size.width, height: adFrame!.size.height)
            self.tableView.tableFooterView?.frame = newAdFrame
        }
    }
}
