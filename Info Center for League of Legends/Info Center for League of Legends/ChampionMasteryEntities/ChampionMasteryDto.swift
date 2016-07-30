//
//  ChampionMasteryDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ChampionMasteryDto: NSObject {
    var championId: CLong = 0
    var championLevel: Int = 0
    var championPoints: Int = 0
    var championPointsSinceLastLevel: CLong = 0
    var championPointsUntilNextLevel: CLong = 0
    var chestGranted:Bool = false
    var lastPlayTime: CLong = 0
    var playerId:CLong = 0
}
