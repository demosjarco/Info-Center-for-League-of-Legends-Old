//
//  ProfileView_RecentGames.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Foundation

protocol RecentGames_SummaryTileDelegate {
    
}

class ProfileView_RecentGames: ProfileView_SummaryTile {
    var delegate:RecentGames_SummaryTileDelegate?
    
    @IBOutlet var winratePercentage: UILabel?
    
    // Last game
    @IBOutlet var lastGameChamp: UIImageView?
    @IBOutlet var lastGameScore: UILabel?
}
