//
//  Profile_Runes_RunesView.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/19/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit
import AMPopTip

class Profile_Runes_RunesView: MainCollectionViewController {
    var pageSelected = RunePageDto()
    var run_currentPage_stats = [String: Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "runeStatCell", for: indexPath) as! ProfileView_Rune_StatsCell
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let popTip = AMPopTip()
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)!
        let cellRect = collectionView.convert(attributes.frame, to: self.view)
        
        popTip.borderWidth = 2
        popTip.borderColor = UIColor(red: 70.0/255.0, green: 55.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        popTip.popoverColor = UIColor(red: 1.0/255.0, green: 10.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        popTip.textAlignment = .center
        
        popTip.showText("Test", direction: AMPopTipDirection.none, maxWidth: self.view.frame.size.width * 0.8, in: self.view, fromFrame: cellRect)
    }
}
