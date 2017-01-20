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
        refresher.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.collectionView?.insertSubview(refresher, at: self.collectionView!.subviews.count - 1)
        
        self.refresh(refresher)
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        
        ChampionMasteryEndpoint().getAllChampsBySummonerId(self.summoner.summonerId, completion: { (champions) in
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.layer.shouldRasterize = true
        // Clear
        cell.championIcon?.image = nil
        cell.championName?.text = "--"
        // Configure the cell
        autoreleasepool(invoking: { ()
            if let champIcon = DDragon().getLcuChampionSquareArt(championMasteries[indexPath.item].championId) {
                cell.championIcon?.image = champIcon
            } else {
                StaticDataEndpoint().getChampionInfoById(championMasteries[indexPath.item].championId, championData: .Image, completion: { (champion) in
                    // Use the new LCU icon if exists
                    DDragon().getChampionSquareArt(champion.image!.full, completion: { (champSquareArtUrl) in
                        cell.championIcon?.setImageWith(URLRequest(url: champSquareArtUrl), placeholderImage: nil, success: { (request, response, image) in
                            cell.championIcon?.image = image
                        }, failure: nil)
                    })
                    cell.championName?.text = champion.name
                }, notFound: {
                    // 404
                }, errorBlock: {
                    // Error
                })
            }
        })
        
        cell.progressBar?.value = CGFloat(championMasteries[indexPath.item].championPointsSinceLastLevel)
        cell.progressBar?.maxValue = CGFloat(championMasteries[indexPath.item].championPointsSinceLastLevel + championMasteries[indexPath.item].championPointsUntilNextLevel)
        
        cell.rankIcon?.image = UIImage(named: "rank" + String(championMasteries[indexPath.item].championLevel))
        
        if championMasteries[indexPath.item].championPointsUntilNextLevel > 0 {
            cell.progressText?.text = String(championMasteries[indexPath.item].championPoints) + " / " + String(championMasteries[indexPath.item].championPoints + championMasteries[indexPath.item].championPointsUntilNextLevel)
        } else {
            cell.progressText?.text = String(championMasteries[indexPath.item].championPoints)
        }
        
        return cell
    }
}
