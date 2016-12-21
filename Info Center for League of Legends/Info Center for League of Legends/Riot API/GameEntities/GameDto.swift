//
//  GameDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class GameDto: NSObject {
    /// Champion ID associated with game.
    var championId:Int = 0
    /// Date that end game data was recorded, specified as epoch milliseconds.
    var createDate = Date()
    /// Other players associated with the game.
    var fellowPlayers = [PlayerDto]()
    /// Game ID.
    var gameId:CLong = 0
    /// Game mode. (Legal values: CLASSIC, ODIN, ARAM, TUTORIAL, ONEFORALL, ASCENSION, FIRSTBLOOD, KINGPORO)
    var gameMode = ""
    /// Game type. (Legal values: CUSTOM_GAME, MATCHED_GAME, TUTORIAL_GAME)
    var gameType = ""
    /// Invalid flag.
    var invalid = false
    /// IP Earned.
    var ipEarned:Int = 0
    /// Level.
    var level:Int = 0
    /// Map ID.
    var mapId:Int = 0
    /// ID of first summoner spell.
    var spell1:Int = 0
    /// ID of second summoner spell.
    var spell2:Int = 0
    /// Statistics associated with the game for this summoner.
    var stats = RawStatsDto()
    /// Game sub-type. (Legal values: NONE, NORMAL, BOT, RANKED_SOLO_5x5, RANKED_PREMADE_3x3, RANKED_PREMADE_5x5, ODIN_UNRANKED, RANKED_TEAM_3x3, RANKED_TEAM_5x5, NORMAL_3x3, BOT_3x3, CAP_5x5, ARAM_UNRANKED_5x5, ONEFORALL_5x5, FIRSTBLOOD_1x1, FIRSTBLOOD_2x2, SR_6x6, URF, URF_BOT, NIGHTMARE_BOT, ASCENSION, HEXAKILL, KING_PORO, COUNTER_PICK, BILGEWATER, SIEGE, RANKED_FLEX_SR, RANKED_FLEX_TT)
    var subType = ""
    /// Team ID associated with game. Team ID 100 is blue team. Team ID 200 is purple team.
    var teamId:Int = 0
}
