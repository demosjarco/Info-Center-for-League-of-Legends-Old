//
//  Profile_ChampionMastery_Cell.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/11/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class Profile_ChampionMastery_Cell: UICollectionViewCell {
    @IBOutlet var championIcon:UIImageView?
    @IBOutlet var progressBar:MBCircularProgressBarView?
    @IBOutlet var rankIcon:UIImageView?
    @IBOutlet var progressText:UILabel?
    @IBOutlet var championName:UILabel?
}
