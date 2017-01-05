//
//  ChampionDetail_Content.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/4/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit

class ChampionDetail_Content: UICollectionViewController {
    var champion = ChampionDto()

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
