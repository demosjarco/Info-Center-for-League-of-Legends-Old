//
//  CurrentGameInfo.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class CurrentGameInfo: NSObject {
    var bannedChampions = [BannedChampion]()
    var gameId:CLong = 0
    var gameLength:CLong = 0
    var gameMode = ""
    var gameQueueConfigId:CLong = 0
    var gameStartTime:CLong = 0
    var gameType = ""
    var mapId:CLong = 0
    var observers = Observer()
    var participants = [CurrentGameParticipant]()
    var platformId = ""
}
