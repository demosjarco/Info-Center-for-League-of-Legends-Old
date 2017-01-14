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
    @IBOutlet weak var championIcon:UIImageView?
    @IBOutlet weak var championIconDark:UIView?
    @IBOutlet weak var progressBar:MBCircularProgressBarView?
    @IBOutlet weak var rankIcon:UIImageView?
    @IBOutlet weak var progressText:UILabel?
    @IBOutlet weak var championName:UILabel?
}
