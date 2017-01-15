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
    
    var championForSegue = ChampionDto()

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
        
        autoreleasepool { ()
            ChampionEndpoint().getAllChampions(false, completion: { (championList) in
                for champion in championList.champions {
                    autoreleasepool(invoking: { ()
                        StaticDataEndpoint().getChampionInfoById(Int(champion.champId), championData: StaticDataEndpoint.champData.All, completion: { (champInfo) in
                            if champion.freeToPlay {
                                self.champions[0].append(champInfo)
                                self.collectionView?.insertItems(at: [IndexPath(item: self.champions[0].index(of: champInfo)!, section: 0)])
                            } else {
                                self.champions[1].append(champInfo)
                                self.collectionView?.insertItems(at: [IndexPath(item: self.champions[1].index(of: champInfo)!, section: 1)])
                            }
                            
                            autoreleasepool(invoking: { ()
                                var oldSection = self.champions[0]
                                self.champions[0].sort(by: { (champ1, champ2) -> Bool in
                                    return champ1.name < champ2.name
                                })
                                for champInfo2 in self.champions[0] {
                                    if oldSection.index(of: champInfo2) != self.champions[0].index(of: champInfo2) {
                                        self.collectionView?.moveItem(at: IndexPath(item: oldSection.index(of: champInfo2)!, section: 0), to: IndexPath(item: self.champions[0].index(of: champInfo2)!, section: 0))
                                        oldSection.remove(at: oldSection.index(of: champInfo2)!)
                                        oldSection.insert(champInfo2, at: self.champions[0].index(of: champInfo2)!)
                                    }
                                }
                            })
                            
                            autoreleasepool(invoking: { ()
                                var oldSection = self.champions[1]
                                self.champions[1].sort(by: { (champ1, champ2) -> Bool in
                                    return champ1.name < champ2.name
                                })
                                for champInfo2 in self.champions[1] {
                                    if oldSection.index(of: champInfo2) != self.champions[1].index(of: champInfo2) {
                                        self.collectionView?.moveItem(at: IndexPath(item: oldSection.index(of: champInfo2)!, section: 1), to: IndexPath(item: self.champions[1].index(of: champInfo2)!, section: 1))
                                        oldSection.remove(at: oldSection.index(of: champInfo2)!)
                                        oldSection.insert(champInfo2, at: self.champions[1].index(of: champInfo2)!)
                                    }
                                }
                            })
                            
                            if self.champions[0].count + self.champions[1].count == championList.champions.count {
                                DispatchQueue.main.async { [unowned self] in
                                    self.refresher?.endRefreshing()
                                }
                            }
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
                self.navigationItem.prompt = "Error, report has been submitted"
            })
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showChampionInfo" {
            let destination = segue.destination as! ChampionDetail
            destination.champion = championForSegue
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.champions[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champCell", for: indexPath) as! ChampionListCell
        // Performance
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.layer.shouldRasterize = true
        
        // Border
        cell.champIconZoomHolder?.layer.borderColor = UIColor(red: 207/255.0, green: 186/255.0, blue: 107/255.0, alpha: 1.0).cgColor
        
        // Clear cell
        cell.champIcon?.image = nil
        cell.freeToPlayBanner?.isHidden = true
        cell.champName?.text = "--"
        
        // Configure the cell
        autoreleasepool { ()
            // Use the new LCU icon if exists
            if let champIcon = DDragon().getLcuChampionSquareArt(self.champions[indexPath.section][indexPath.row].champId) {
                cell.champIcon?.image = champIcon
            } else {
                DDragon().getChampionSquareArt(self.champions[indexPath.section][indexPath.row].image!.full, completion: { (champSquareArtUrl) in
                    autoreleasepool(invoking: { ()
                        cell.champIcon?.setImageWith(URLRequest(url: champSquareArtUrl), placeholderImage: nil, success: { (request, response, image) in
                            if ((cell.champIcon?.image) == nil) {
                                cell.champIcon?.image = image
                            }
                        }, failure: nil)
                    })
                })
            }
        }
        
        cell.freeToPlayBanner?.isHidden = indexPath.section == 1 ? true : false
        
        cell.champName?.text = self.champions[indexPath.section][indexPath.row].name
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.championForSegue = self.champions[indexPath.section][indexPath.row]
        return true
    }
}
