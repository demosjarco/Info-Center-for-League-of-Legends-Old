//
//  ChampionDetail_SkinBg.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/4/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit

class ChampionDetail_SkinBg: UIViewController {
    @IBOutlet var skinImage:UIImageView?
    
    var fullImageName = ""
    var skinNum = 0
    var pageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.traitCollection.horizontalSizeClass == .regular {
            DDragon().getChampionSplashArt(self.fullImageName, skinNumber: skinNum) { (champSplashArtUrl) in
                self.skinImage?.setImageWith(champSplashArtUrl)
            }
        } else {
            DDragon().getChampionLoadingArt(self.fullImageName, skinNumber: skinNum, completion: { (champSplashArtUrl) in
                self.skinImage?.setImageWith(champSplashArtUrl)
            })
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.skinImage?.image = nil
        if newCollection.horizontalSizeClass == .regular {
            DDragon().getChampionSplashArt(self.fullImageName, skinNumber: skinNum) { (champSplashArtUrl) in
                self.skinImage?.setImageWith(champSplashArtUrl)
            }
        } else {
            DDragon().getChampionLoadingArt(self.fullImageName, skinNumber: skinNum, completion: { (champSplashArtUrl) in
                self.skinImage?.setImageWith(champSplashArtUrl)
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
