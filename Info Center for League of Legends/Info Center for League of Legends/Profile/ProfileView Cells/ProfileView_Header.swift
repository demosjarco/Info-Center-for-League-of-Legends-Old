//
//  ProfileView_Header.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Foundation

class ProfileView_Header: UICollectionReusableView {
    var summoner = SummonerDto()
    
    @IBOutlet var cover:UIImageView?
    
    @IBOutlet var promotionGames:UILabel?
    @IBOutlet var summonerName:UILabel?
    @IBOutlet var summonerLevelRank:UILabel?
    @IBOutlet var summonerChampMasteryScore:UILabel?
    
    @IBOutlet var profilePic:UIImageView?
    @IBOutlet var statsScroller:UICollectionView?
    
    func initialLoad(loadedSummoner: SummonerDto) {
        self.summoner = loadedSummoner
        
        DDragon().getProfileIcon(profileIconId: self.summoner.profileIconId, completion: { (profileIconURL) in
            self.cover?.setImageWith(URLRequest(url: profileIconURL), placeholderImage: UIImage(named: "poroIcon"), success: { (request, response, image) in
                self.cover?.image = image
                self.profilePic?.image = image
                
                self.profilePic?.layer.cornerRadius = (self.profilePic?.frame.size.height)! / 2
                }, failure: { (request, response, error) in
                    self.cover?.image = UIImage(named: "poroIcon")
                    self.profilePic?.image = UIImage(named: "poroIcon")
                    
                    self.profilePic?.layer.cornerRadius = (self.profilePic?.frame.size.height)! / 2
            })
        })
    }
}
