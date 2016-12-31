//
//  CurrentGameParticipant.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class CurrentGameParticipant: NSObject {
    var bot = false
    var championId:CLong = 0
    var masteries = [MasteryDto]()
    var profileIconId:CLong = 0
    var runes = [AnyObject]()
    var spell1Id:CLong = 0
    var spell2Id:CLong = 0
    var summonerId:CLong = 0
    var summonerName = ""
    var teamId:CLong = 0
}
