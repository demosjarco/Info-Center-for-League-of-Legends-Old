//
//  ChampionList.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 10/7/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ChampionList: MainCollectionViewController {
    @IBOutlet var refresher:UIRefreshControl?
    
    var champions = [[ChampionDto](), [ChampionDto]()]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl(frame: self.collectionView!.frame)
        refresher?.tintColor = UIColor.lightText
        refresher?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.collectionView?.insertSubview(refresher!, at: self.collectionView!.subviews.count - 1)
        
        refresh()
    }
    
    @IBAction func refresh() {
        refresher?.beginRefreshing()
        self.champions = [[ChampionDto](), [ChampionDto]()]
        self.collectionView?.reloadData()
        
        ChampionEndpoint().getAllChampions(false, completion: { (championList) in
            for champion in championList.champions {
                autoreleasepool(invoking: { ()
                    StaticDataEndpoint().getChampionInfoById(Int(champion.champId), championData: StaticDataEndpoint.champData.Image, completion: { (champInfo) in
                        autoreleasepool(invoking: { ()
                            if champion.freeToPlay {
                                self.champions[0].append(champInfo)
                                self.collectionView?.reloadSections(IndexSet(integer: 0))
                            } else {
                                self.champions[1].append(champInfo)
                                self.collectionView?.reloadSections(IndexSet(integer: 1))
                            }
                            
                            self.champions[0].sort(by: { (champ1, champ2) -> Bool in
                                return champ1.name < champ2.name
                            })
                            self.collectionView?.reloadSections(IndexSet(integer: 0))
                            
                            self.champions[1].sort(by: { (champ1, champ2) -> Bool in
                                return champ1.name < champ2.name
                            })
                            self.collectionView?.reloadSections(IndexSet(integer: 1))
                            
                            if self.champions[0].count + self.champions[1].count == championList.champions.count {
                                self.refresher?.endRefreshing()
                            }
                        })
                    }, notFound: {
                        // ??
                        self.refresher?.endRefreshing()
                    }, errorBlock: {
                        // Error
                        self.refresher?.endRefreshing()
                    })
                })
            }
        }, errorBlock: {
            // Error
            self.refresher?.endRefreshing()
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.champions.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.champions[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champCell", for: indexPath) as! ChampionListCell
        // Clear cell
        cell.champIcon?.image = nil
        
        // Configure the cell
        // Use the new LCU icon if exists
        if let champIcon = DDragon().getLcuChampionSquareArt(champId: self.champions[indexPath.section][indexPath.row].champId) {
            cell.champIcon?.image = champIcon
        } else {
            DDragon().getChampionSquareArt(self.champions[indexPath.section][indexPath.row].image!.full, completion: { (champSquareArtUrl) in
                cell.champIcon?.setImageWith(champSquareArtUrl)
            })
        }
        
        cell.freeToPlayBanner?.isHidden = indexPath.section == 1 ? true : false
        
        cell.champName?.text = self.champions[indexPath.section][indexPath.row].name
    
        return cell
    }
}
