//
//  Profile_Masteries_MasteriesView.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/21/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_Masteries_MasteriesView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    var summoner = SummonerDto()
    var pageId:CLong = 0
    
    @IBOutlet var sectionBar:UISegmentedControl?
    @IBOutlet var treeScrollView:UIScrollView?
    @IBOutlet var masteryBg:UIImageView?
    @IBOutlet var ferocityTree: UICollectionView?
    @IBOutlet var cunningTree: UICollectionView?
    @IBOutlet var resolveTree: UICollectionView?
    
    var ferocityMasteries = [MasteryTreeListDto]()
    var cunningMasteries = [MasteryTreeListDto]()
    var resolveMasteries = [MasteryTreeListDto]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        treeScrollView?.contentSize = masteryBg!.bounds.size
        
        refresh()
    }
    
    func refresh() {
        StaticDataEndpoint().getMasteryInfo(.All, completion: { (masteryList) in
            self.ferocityMasteries = masteryList.tree!.ferocity
            self.cunningMasteries = masteryList.tree!.cunning
            self.resolveMasteries = masteryList.tree!.resolve
            
            SummonerEndpoint().getMasteriesForSummonerIds([self.summoner.summonerId], completion: { (summonerMap) in
                for masteryPage in summonerMap.values.first!.pages {
                    if masteryPage.masteryPageId == self.pageId {
                        // Current page
                        self.navigationItem.prompt = masteryPage.name
                        
                        for mastery1 in masteryPage.masteries {
                            for row in self.ferocityMasteries {
                                for mastery2 in row.masteryTreeItems {
                                    if mastery1.masteryId == mastery2.masteryId {
                                        mastery2.points = mastery1.rank
                                        break
                                    }
                                }
                            }
                            
                            for row in self.cunningMasteries {
                                for mastery2 in row.masteryTreeItems {
                                    if mastery1.masteryId == mastery2.masteryId {
                                        mastery2.points = mastery1.rank
                                        break
                                    }
                                }
                            }
                            
                            for row in self.resolveMasteries {
                                for mastery2 in row.masteryTreeItems {
                                    if mastery1.masteryId == mastery2.masteryId {
                                        mastery2.points = mastery1.rank
                                        break
                                    }
                                }
                            }
                        }
                        
                        self.ferocityTree?.reloadData()
                        self.resolveTree?.reloadData()
                        self.cunningTree?.reloadData()
                        
                        break
                    }
                }
            }, errorBlock: {
                // Error
            })
        }) {
            // Error
        }
    }
    
    @IBAction func jumpToSection() {
        if sectionBar!.selectedSegmentIndex == 0 {
            treeScrollView?.scrollRectToVisible(ferocityTree!.frame, animated: true)
        } else if sectionBar!.selectedSegmentIndex == 1 {
            treeScrollView?.scrollRectToVisible(cunningTree!.frame, animated: true)
        } else if sectionBar!.selectedSegmentIndex == 2 {
            treeScrollView?.scrollRectToVisible(resolveTree!.frame, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == treeScrollView {
            if scrollView.contentOffset.x < ferocityTree!.frame.size.width / 2 {
                sectionBar?.selectedSegmentIndex = 0
            } else if scrollView.contentOffset.x >= ferocityTree!.frame.size.width / 2 && scrollView.contentOffset.x <= cunningTree!.frame.origin.x + cunningTree!.frame.size.width / 2 {
                sectionBar?.selectedSegmentIndex = 1
            } else if scrollView.contentOffset.x > cunningTree!.frame.origin.x + cunningTree!.frame.size.width / 2 {
                sectionBar?.selectedSegmentIndex = 2
            }
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case ferocityTree!:
            return ferocityMasteries.count
        case cunningTree!:
            return cunningMasteries.count
        case resolveTree!:
            return resolveMasteries.count
        default:
            return 0
        }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case ferocityTree!:
            if ferocityMasteries.count > 0 {
                return ferocityMasteries[section].masteryTreeItems.count
            } else {
                return 0
            }
        case cunningTree!:
            if cunningMasteries.count > 0 {
                return cunningMasteries[section].masteryTreeItems.count
            } else {
                return 0
            }
        case resolveTree!:
            if resolveMasteries.count > 0 {
                return resolveMasteries[section].masteryTreeItems.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "masteryCell", for: indexPath) as! Profile_Masteries_MasteriesView_Cell
    
        // Configure the cell
        switch collectionView {
        case ferocityTree!:
            DDragon().getMasteryIcon(ferocityMasteries[indexPath.section].masteryTreeItems[indexPath.row].masteryId, gray: ferocityMasteries[indexPath.section].masteryTreeItems[indexPath.row].points > 0 ? false : true, completion: { (masteryIconUrl) in
                cell.masteryImage?.setImageWith(masteryIconUrl)
            })
            cell.masteryLevel?.text = " " + String(ferocityMasteries[indexPath.section].masteryTreeItems[indexPath.row].points) + " / " + String(masteryData[String(ferocityMasteries[indexPath.section].masteryTreeItems[indexPath.row].masteryId)]!.ranks!)
            
            break
        case cunningTree!:
            DDragon().getMasteryIcon(cunningMasteries[indexPath.section].masteryTreeItems[indexPath.row].masteryId, gray: cunningMasteries[indexPath.section].masteryTreeItems[indexPath.row].points > 0 ? false : true, completion: { (masteryIconUrl) in
                cell.masteryImage?.setImageWith(masteryIconUrl)
            })
            cell.masteryLevel?.text = " " + String(cunningMasteries[indexPath.section].masteryTreeItems[indexPath.row].points) + " / " + String(masteryData[String(cunningMasteries[indexPath.section].masteryTreeItems[indexPath.row].masteryId)]!.ranks!)
            
            break
        case resolveTree!:
            DDragon().getMasteryIcon(resolveMasteries[indexPath.section].masteryTreeItems[indexPath.row].masteryId, gray: resolveMasteries[indexPath.section].masteryTreeItems[indexPath.row].points > 0 ? false : true, completion: { (masteryIconUrl) in
                cell.masteryImage?.setImageWith(masteryIconUrl)
            })
            cell.masteryLevel?.text = " " + String(resolveMasteries[indexPath.section].masteryTreeItems[indexPath.row].points) + " / " + String(masteryData[String(resolveMasteries[indexPath.section].masteryTreeItems[indexPath.row].masteryId)]!.ranks!)
            
            break
        default:
            break
        }
        
        return cell
    }
}
