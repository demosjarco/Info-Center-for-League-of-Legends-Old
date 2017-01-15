//
//  ChampionDetail_SkinBg.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/4/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import XCDYouTubeKit

class ChampionDetail_SkinBg: UIViewController {
    @IBOutlet weak var skinImage:UIImageView?
    weak var animatedSkinVideo:AVPlayer?
    weak var animatedSkinVideoLayer:AVPlayerLayer?
    
    var fullImageName = ""
    var champId = 0
    var skinNum = 0
    var pageIndex = 0
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setContentWithTraitCollection(self.traitCollection)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        setContentWithTraitCollection(newCollection)
    }
    
    func setContentWithTraitCollection(_ collection: UITraitCollection) {
        if collection.containsTraits(in: UITraitCollection(horizontalSizeClass: .regular)) {
            FIRDatabase.database().reference().child("champExtraInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("\(self.champId)") {
                    if snapshot.childSnapshot(forPath: "\(self.champId)").childSnapshot(forPath: "skins").hasChild("\(self.skinNum)") {
                        if snapshot.childSnapshot(forPath: "\(self.champId)").childSnapshot(forPath: "skins").childSnapshot(forPath: "\(self.skinNum)").hasChild("animatedVideoIds") {
                            autoreleasepool(invoking: { ()
                                // Animated Splash available
                                let reachability = Reachability.forInternetConnection()
                                reachability?.startNotifier()
                                
                                switch reachability!.currentReachabilityStatus() {
                                case ReachableViaWWAN:
                                    // Cellular
                                    if UserDefaults.standard.value(forKey: "league_useAnimatedSplashArtOnCellular") != nil {
                                        // animated splash on cellular key set
                                        if UserDefaults.standard.bool(forKey: "league_useAnimatedSplashArtOnCellular") {
                                            // Animated
                                            self.loadAnimatedPlayer(snapshot.childSnapshot(forPath: "\(self.champId)").childSnapshot(forPath: "skins").childSnapshot(forPath: "\(self.skinNum)").childSnapshot(forPath: "animatedVideoIds"))
                                        } else {
                                            // Static
                                            DDragon().getChampionSplashArt(self.fullImageName, skinNumber: self.skinNum) { (champSplashArtUrl) in
                                                self.skinImage?.setImageWith(champSplashArtUrl)
                                            }
                                        }
                                    } else {
                                        // animated splash on cellular key never set
                                        UserDefaults.standard.set(false, forKey: "league_useAnimatedSplashArtOnCellular")
                                        // Static
                                        DDragon().getChampionSplashArt(self.fullImageName, skinNumber: self.skinNum) { (champSplashArtUrl) in
                                            self.skinImage?.setImageWith(champSplashArtUrl)
                                        }
                                    }
                                    break
                                case ReachableViaWiFi:
                                    // WiFi
                                    // Animated
                                    self.loadAnimatedPlayer(snapshot.childSnapshot(forPath: "\(self.champId)").childSnapshot(forPath: "skins").childSnapshot(forPath: "\(self.skinNum)").childSnapshot(forPath: "animatedVideoIds"))
                                    break
                                default:
                                    break
                                }
                            })
                        } else {
                            // Animated skin video ids not in my database
                            // Animated splash not available
                            DDragon().getChampionSplashArt(self.fullImageName, skinNumber: self.skinNum) { (champSplashArtUrl) in
                                self.skinImage?.setImageWith(champSplashArtUrl)
                            }
                        }
                    } else {
                        // Skin not in my database
                        // Animated splash not available
                        DDragon().getChampionSplashArt(self.fullImageName, skinNumber: self.skinNum) { (champSplashArtUrl) in
                            self.skinImage?.setImageWith(champSplashArtUrl)
                        }
                    }
                } else {
                    // Champ not in my database
                    // Animated splash not available
                    DDragon().getChampionSplashArt(self.fullImageName, skinNumber: self.skinNum) { (champSplashArtUrl) in
                        self.skinImage?.setImageWith(champSplashArtUrl)
                    }
                }
            })
        } else {
            self.animatedSkinVideo?.pause()
            DDragon().getChampionLoadingArt(self.fullImageName, skinNumber: skinNum, completion: { (champSplashArtUrl) in
                self.skinImage?.setImageWith(champSplashArtUrl)
            })
        }
    }
    
    func loadAnimatedPlayer(_ snapshot: FIRDataSnapshot) {
        autoreleasepool { ()
            let videoIds = snapshot.value as! [String]
            let randomIndex = Int(arc4random_uniform(UInt32(videoIds.count)))
            let videoId = videoIds[randomIndex]
            XCDYouTubeClient.default().getVideoWithIdentifier(videoId, completionHandler: { (video, error) in
                autoreleasepool(invoking: { ()
                    var bestQualityURL:URL?
                    
                    if let url = video?.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)] {
                        bestQualityURL = url
                    } else if let url = video?.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)] {
                        bestQualityURL = url
                    } else if let url = video?.streamURLs[NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)] {
                        bestQualityURL = url
                    }
                    
                    if let url = bestQualityURL {
                        self.animatedSkinVideo = AVPlayer.init(playerItem: AVPlayerItem(url: url))
                        self.animatedSkinVideo?.isMuted = true
                        self.animatedSkinVideo?.actionAtItemEnd = .none
                        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.animatedSkinVideo?.currentItem)
                        
                        self.animatedSkinVideoLayer = AVPlayerLayer.init(player: self.animatedSkinVideo)
                        self.animatedSkinVideoLayer?.frame = self.skinImage!.frame
                        self.animatedSkinVideoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                        self.view.layer.insertSublayer(self.animatedSkinVideoLayer!, below: self.skinImage?.layer)
                        
                        self.animatedSkinVideo?.play()
                    } else {
                        DDragon().getChampionSplashArt(self.fullImageName, skinNumber: self.skinNum) { (champSplashArtUrl) in
                            self.skinImage?.setImageWith(champSplashArtUrl)
                        }
                    }
                })
            })
        }
    }
    
    func playerItemDidReachEnd(_ notification: Notification) {
        let p = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
