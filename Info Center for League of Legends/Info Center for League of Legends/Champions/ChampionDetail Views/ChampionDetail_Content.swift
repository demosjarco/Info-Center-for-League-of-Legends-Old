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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Blur BG
        autoreleasepool { ()
            let tableBG = UIVisualEffectView(frame: self.collectionView!.frame)
            tableBG.effect = UIBlurEffect(style: .dark)
            tableBG.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            self.collectionView?.backgroundView = tableBG
        }
    }
    
    func goBack() {
        self.delegate?.goBack()
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
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "champion_view_header", for: indexPath) as! ChampionDetail_Content_Header
            
            profileHeader.delegate = self
            
            return profileHeader
        case UICollectionElementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        default:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "<#reuseIdentifier#>", for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
}
