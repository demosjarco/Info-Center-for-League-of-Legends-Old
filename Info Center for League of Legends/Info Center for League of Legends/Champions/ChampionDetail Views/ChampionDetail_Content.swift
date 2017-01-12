//
//  ChampionDetail_Content.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/4/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit

protocol ChampViewDelegate {
    func goBack()
}

class ChampionDetail_Content: UICollectionViewController, ChampViewHeaderDelegate {
    var delegate:ChampViewDelegate?
    var champion = ChampionDto()
    var tileOrder = NSArray()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func goBack() {
        self.delegate?.goBack()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Blur BG
        autoreleasepool { ()
            let tableBG = UIVisualEffectView(frame: self.collectionView!.frame)
            tableBG.effect = UIBlurEffect(style: .dark)
            tableBG.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            self.collectionView?.backgroundView = tableBG
        }
        
        tileOrder = PlistManager().loadChampionDetailViewTileOrder()
        
        loadContent()
    }
    
    func loadContent() {
        
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
        return tileOrder.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "champion_view_header", for: indexPath) as! ChampionDetail_Content_Header
            
            profileHeader.delegate = self
            profileHeader.stats = self.champion.stats!
            
            DDragon().getChampionSplashArt(self.champion.image!.full, skinNumber: 0, completion: { (champSquareArtUrl) in
                profileHeader.championCover?.setImageWith(champSquareArtUrl)
            })
            
            // Use the new LCU icon if exists
            if let champIcon = DDragon().getLcuChampionSquareArt(champId: self.champion.champId) {
                profileHeader.championIcon?.image = champIcon
            } else {
                DDragon().getChampionSquareArt(self.champion.image!.full, completion: { (champSquareArtUrl) in
                    profileHeader.championIcon?.setImageWith(champSquareArtUrl)
                })
            }
            
            return profileHeader
        case UICollectionElementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let niceTileOrder = tileOrder as! [[String: String]]
        switch niceTileOrder[indexPath.row]["tileType"] {
        case "allyTips" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_allyTips", for: indexPath) as! ChampionDetail_Content_AllyTips
            
            // Configure the cell
            
            return cell
        case "enemyTips" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_enemyTips", for: indexPath)
            
            // Configure the cell
            
            return cell
        case "lore" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_lore", for: indexPath)
            
            // Configure the cell
            
            return cell
        case "passive" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_passive", for: indexPath)
            
            // Configure the cell
            
            return cell
        case "spell0" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_spell", for: indexPath)
            
            // Configure the cell
            
            return cell
        case "spell1" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_spell", for: indexPath)
            
            // Configure the cell
            
            return cell
        case "spell2" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_spell", for: indexPath)
            
            // Configure the cell
            
            return cell
        case "spell3" as NSString:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_spell", for: indexPath)
            
            // Configure the cell
            
            return cell
        default:
            // ??
            return collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let newTileOrder = NSMutableArray(array: tileOrder)
        newTileOrder.removeObject(at: sourceIndexPath.row)
        newTileOrder.insert(tileOrder[sourceIndexPath.row], at: destinationIndexPath.row)
        PlistManager().writeChampionDetailViewTileOrder(NSArray(array: newTileOrder))
        
        tileOrder = NSArray(array: newTileOrder)
    }
}
