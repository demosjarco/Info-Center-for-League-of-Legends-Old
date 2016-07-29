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
import BEMSimpleLineGraph

protocol HeaderDelegate {
    func goBack()
    func addSummonerToRecents()
}

class ProfileView_Header: UICollectionReusableView, BEMSimpleLineGraphDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    var delegate:HeaderDelegate?
    var summoner = SummonerDto()
    var summonerStats = NSMutableArray()
    
    @IBOutlet var cover:UIImageView?
    @IBOutlet var addSummonerButton:UIButton?
    
    @IBOutlet var promotionGames:UILabel?
    @IBOutlet var summonerName:UILabel?
    @IBOutlet var summonerLevelRank:UILabel?
    @IBOutlet var summonerLevelRankIcon:UIImageView?
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
        
        self.setupSummonerStats()
        self.downloadProfileIconCover()
    }
    
    func setupSummonerStats() {
        self.summonerStats.add(NSMutableDictionary(objects: ["Ranked Wins", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Ranked Losses", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["League Points", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal Takedowns", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal CS", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Normal Wins", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Kills", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Towers Destroyed", "--"], forKeys: ["statTitle", "statValue"]))
        self.summonerStats.add(NSMutableDictionary(objects: ["Aram Wins", "--"], forKeys: ["statTitle", "statValue"]))
    }
    
    func downloadProfileIconCover() {
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
            shadowLayer.shadowOpacity = 0.5
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
    
    // MARK: - Graph Delegate
    
    // MARK: - Graph Data Source
    func numberOfPoints(inLineGraph graph: BEMSimpleLineGraphView) -> Int {
        return Int(arc4random_uniform(50) + 2)
    }
    
    func lineGraph(_ graph: BEMSimpleLineGraphView, valueForPointAt index: Int) -> CGFloat {
        return CGFloat(arc4random_uniform(100) + 2)
    }
    
    // MARK: - Collection view data source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.summonerStats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileStats", for: indexPath) as! ProfileView_Header_StatsCell
        
        if indexPath.row == 0 {
            cell.leftBorder?.isHidden = true
        } else {
            cell.leftBorder?.isHidden = false
        }
        if indexPath.row == self.summonerStats.count - 1 {
            cell.rightBorder?.isHidden = true
        } else {
            cell.rightBorder?.isHidden = false
        }
        
        cell.statTitle?.text = self.summonerStats[indexPath.row]["statTitle"] as? String
        cell.statValue?.text = self.summonerStats[indexPath.row]["statValue"] as? String
        
        return cell
    }
}
