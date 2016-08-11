//
//  Profile_ChampionMastery.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/11/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_ChampionMastery: MainCollectionViewController {
    var summoner = SummonerDto()
    var championMasteries = [ChampionMasteryDto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresher = UIRefreshControl(frame: self.collectionView!.frame)
        refresher.tintColor = UIColor.lightText
        refresher.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        self.collectionView?.insertSubview(refresher, at: self.collectionView!.subviews.count - 1)
        
        self.refresh(sender: refresher)
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        sender.beginRefreshing()
        
        ChampionMasteryEndpoint().getAllChampsBySummonerId(playerId: self.summoner.summonerId, completion: { (champions) in
            // Stuff
            self.championMasteries = champions
            self.collectionView?.reloadSections(IndexSet(integer: 0))
            sender.endRefreshing()
        }, notFound: {
            // ???
            sender.endRefreshing()
        }, errorBlock: {
            // Error
            sender.endRefreshing()
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return championMasteries.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "championMasteryCell", for: indexPath) as! Profile_ChampionMastery_Cell
        // Performance
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        // Configure the cell
    
        return cell
    }
}
