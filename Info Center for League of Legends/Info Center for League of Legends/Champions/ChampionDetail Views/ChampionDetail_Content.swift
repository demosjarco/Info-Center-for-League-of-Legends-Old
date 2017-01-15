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
        return self.champion.spells?.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "champion_view_header", for: indexPath) as! ChampionDetail_Content_Header
            
            profileHeader.delegate = self
            profileHeader.stats = self.champion.stats!
            
            profileHeader.championIcon?.layer.borderColor = UIColor(red: 207/255.0, green: 186/255.0, blue: 107/255.0, alpha: 1.0).cgColor
            // Use the new LCU icon if exists
            if let champIcon = DDragon().getLcuChampionSquareArt(champId: self.champion.champId) {
                profileHeader.championIcon?.image = champIcon
            } else {
                DDragon().getChampionSquareArt(self.champion.image!.full, completion: { (champSquareArtUrl) in
                    profileHeader.championIcon?.setImageWith(champSquareArtUrl)
                })
            }
            
            autoreleasepool(invoking: { ()
                let champName = NSAttributedString(string: self.champion.name + " ", attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1), NSForegroundColorAttributeName: UIColor.white])
                let champTitle = NSAttributedString(string: self.champion.title, attributes: [NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline), NSForegroundColorAttributeName: UIColor.lightText])
                let combination = NSMutableAttributedString()
                combination.append(champName)
                combination.append(champTitle)
                profileHeader.championName?.attributedText = combination
            })
            
            return profileHeader
        case UICollectionElementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "champion_view_spell", for: indexPath)
        if indexPath.row == 0 {
            // Passive
        } else {
            // Spells
        }
        
        return cell
    }
}
