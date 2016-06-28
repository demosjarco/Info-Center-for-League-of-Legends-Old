//
//  ProfileView_Header.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

protocol HeaderDelegate {
    func goBack()
    func addSummonerToRecents()
}

class ProfileView_Header: UICollectionReusableView {
    var delegate:HeaderDelegate?
    var summoner = SummonerDto()
    
    @IBOutlet var cover:UIImageView?
    @IBOutlet var addSummonerButton:UIButton?
    
    @IBOutlet var promotionGames:UILabel?
    @IBOutlet var summonerName:UILabel?
    @IBOutlet var summonerLevelRank:UILabel?
    @IBOutlet var summonerChampMasteryScore:UILabel?
    
    @IBOutlet var profilePic:UIImageView?
    @IBOutlet var profilePicShadow:UIView?
    @IBOutlet var statsScroller:UICollectionView?
    
    func initialLoad(loadedSummoner: SummonerDto) {
        self.summoner = loadedSummoner
        self.summonerName?.text = self.summoner.name
        
        // Disable add summoner to recents if already there
        if PlistManager().loadRecentSummoners().contains(self.summoner.summonerId) {
            addSummonerButton?.isEnabled = false
        }
        
        DDragon().getProfileIcon(profileIconId: self.summoner.profileIconId, completion: { (profileIconURL) in
            // Circle profile pic
            self.profilePic?.layer.cornerRadius = (self.profilePic?.frame.size.height)! / 2
            
            self.cover?.setImageWith(URLRequest(url: profileIconURL), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                self.cover?.image = image
                self.profilePic?.image = image
                self.setShadowOnProfilePic()
            }, failure: { (request, response, error) in
                self.cover?.image = UIImage(named: "poroIcon")
                self.profilePic?.image = UIImage(named: "poroIcon")
                self.setShadowOnProfilePic()
            })
        })
    }
    
    func setShadowOnProfilePic() {
        // Rounded shadow on seperate UIView behind profile pic
        autoreleasepool({ ()
            let shadowLayer = CAShapeLayer()
            shadowLayer.shadowColor = UIColor.black().cgColor
            shadowLayer.shadowPath = UIBezierPath(roundedRect: self.profilePicShadow!.bounds, cornerRadius: self.profilePic!.layer.cornerRadius).cgPath
            shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
            shadowLayer.shadowOpacity = 0.35
            shadowLayer.shadowRadius = 27.0
            //spread 15%
            self.profilePicShadow?.layer.addSublayer(shadowLayer)
        })
        self.profilePicShadow?.layer.shouldRasterize = true
    }
    
    @IBAction func backButtonPressed() {
        delegate?.goBack()
    }
    
    @IBAction func addToRecentsPressed() {
        delegate?.addSummonerToRecents()
    }
}
