//
//  RecentGamesDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class RecentGamesDto: NSObject {
    /// Collection of recent games played (max 10).
    var games = [GameDto]()
    /// Summoner ID.
    var summonerId:CLong = 0
}
