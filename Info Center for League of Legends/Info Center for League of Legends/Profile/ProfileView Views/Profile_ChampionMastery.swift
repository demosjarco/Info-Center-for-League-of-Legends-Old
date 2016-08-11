//
//  Profile_ChampionMastery.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/11/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Profile_ChampionMastery: MainCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        /*ChampionMasteryEndpoint().getAllChampsBySummonerId(playerId: <#T##CLong#>, completion: { (champions) in
            // Stuff
        }, notFound: {
            // ???
        }, errorBlock: {
            // Error
        })*/
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
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
        // #warning Incomplete implementation, return the number of items
        return 132
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "championMasteryCell", for: indexPath)
    
        // Configure the cell
    
        return cell
    }
}
