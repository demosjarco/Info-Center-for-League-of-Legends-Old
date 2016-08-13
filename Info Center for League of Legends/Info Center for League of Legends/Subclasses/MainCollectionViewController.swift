//
//  MainCollectionViewController.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class MainCollectionViewController: UICollectionViewController, GADBannerViewDelegate, GADAdSizeDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableBG = UIView(frame: self.collectionView!.frame)
        tableBG.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let bgImage = UIImageView(frame: tableBG.frame)
        tableBG.addSubview(bgImage)
        bgImage.autoresizingMask = tableBG.autoresizingMask
        bgImage.contentMode = .scaleAspectFill
        
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch(completionHandler: { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                
                switch remoteConfig["contentSeason"].numberValue!.intValue {
                case 0:
                    // Snowdown
                    bgImage.image = UIImage(named: "howlingAbyss")
                    break
                case 1:
                    // Normal
                    bgImage.image = UIImage(named: "summonersRift")
                    break
                case 2:
                    // Harrowing
                    bgImage.image = UIImage(named: "shadowIsles")
                    break
                case 3:
                    // URF
                    bgImage.image = UIImage(named: "urfBackground")
                    break
                default:
                    break
                }
            }
        })
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        tableBG.insertSubview(blur, aboveSubview: bgImage)
        blur.frame = tableBG.frame
        blur.autoresizingMask = tableBG.autoresizingMask
        
        self.collectionView?.backgroundView = tableBG
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        self.collectionView?.contentInset = UIEdgeInsets(top: self.collectionView!.contentInset.top, left: self.collectionView!.contentInset.left, bottom: bannerView.adSize.size.height, right: self.collectionView!.contentInset.right)
        
        /*let adFrame = self.tableView.tableFooterView?.frame
        let newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - self.tabBarController!.tabBar.frame.size.height - bannerView.adSize.size.height
        let newAdFrame = CGRect(x: adFrame!.origin.x, y: newOriginY, width: adFrame!.size.width, height: bannerView.adSize.size.height)
        self.tableView.tableFooterView?.frame = newAdFrame*/
    }
    
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        self.collectionView?.contentInset = UIEdgeInsets(top: self.collectionView!.contentInset.top, left: self.collectionView!.contentInset.left, bottom: size.size.height, right: self.collectionView!.contentInset.right)
        
        /*let adFrame = self.tableView.tableFooterView?.frame
        let newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - self.tabBarController!.tabBar.frame.size.height - size.size.height
        let newAdFrame = CGRect(x: adFrame!.origin.x, y: newOriginY, width: adFrame!.size.width, height: bannerView.adSize.size.height)
        self.tableView.tableFooterView?.frame = newAdFrame*/
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*if self.tableView.tableFooterView != nil {
            let adFrame = self.tableView.tableFooterView?.frame
            let newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - self.tabBarController!.tabBar.frame.size.height - adFrame!.size.height
            let newAdFrame = CGRect(x: adFrame!.origin.x, y: newOriginY, width: adFrame!.size.width, height: adFrame!.size.height)
            self.tableView.tableFooterView?.frame = newAdFrame
        }*/
    }
}
