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
import AFNetworking

class MainCollectionViewController: UICollectionViewController, GADBannerViewDelegate, GADAdSizeDelegate {
    weak var adBanner = GADBannerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoreleasepool { ()
            let tableBG = UIView(frame: self.collectionView!.frame)
            tableBG.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            let bgImage = UIImageView(frame: tableBG.frame)
            tableBG.addSubview(bgImage)
            bgImage.autoresizingMask = tableBG.autoresizingMask
            bgImage.contentMode = .scaleAspectFill
            
            let remoteConfig = FIRRemoteConfig.remoteConfig()
            remoteConfig.fetch(completionHandler: { (status, error) in
                autoreleasepool { ()
                    if status == .success {
                        remoteConfig.activateFetched()
                        
                        FIRStorage.storage().reference().child("appBackgrounds").child(remoteConfig["appBackground"].stringValue!).downloadURL(completion: { (url, error) in
                            autoreleasepool { ()
                                if (error != nil) {
                                    // ?
                                } else {
                                    bgImage.setImageWith(url!)
                                }
                            }
                        })
                    }
                }
            })
            
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            tableBG.insertSubview(blur, aboveSubview: bgImage)
            blur.frame = tableBG.frame
            blur.autoresizingMask = tableBG.autoresizingMask
            
            self.collectionView?.backgroundView = tableBG
            
            // Needs to be per view
            /*adBanner?.adUnitID = "ca-app-pub-0612280347500538/2937038010"
             adBanner?.isAutoloadEnabled = true*/
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
