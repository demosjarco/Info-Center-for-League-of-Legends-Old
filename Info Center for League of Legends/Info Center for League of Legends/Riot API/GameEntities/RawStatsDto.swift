//
//  RawStatsDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class RawStatsDto: NSObject {
    ///
    var assists:Int = 0
    /// Number of enemy inhibitors killed.
    var barracksKilled:Int = 0
    ///
    var bountyLevel:Int = 0
    ///
    var championsKilled:Int = 0
    ///
    var combatPlayerScore:Int = 0
    ///
    var consumablesPurchased:Int = 0
    ///
    var damageDealtPlayer:Int = 0
    ///
    var doubleKills:Int = 0
    ///
    var firstBlood:Int = 0
    ///
    var gold:Int = 0
    ///
    var goldEarned:Int = 0
    ///
    var goldSpent:Int = 0
    ///
    var item0:Int = 0
    ///
    var item1:Int = 0
    ///
    var item2:Int = 0
    ///
    var item3:Int = 0
    ///
    var item4:Int = 0
    ///
    var item5:Int = 0
    ///
    var item6:Int = 0
    ///
    var itemsPurchased:Int = 0
    ///
    var killingSprees:Int = 0
    ///
    var largestCriticalStrike:Int = 0
    ///
    var largestKillingSpree:Int = 0
    ///
    var largestMultiKill:Int = 0
    /// Number of tier 3 items built.
    var legendaryItemsCreated:Int = 0
    ///
    var level:Int = 0
    ///
    var magicDamageDealtPlayer:Int = 0
    ///
    var magicDamageDealtToChampions:Int = 0
    ///
    var magicDamageTaken:Int = 0
    ///
    var minionsDenied:Int = 0
    ///
    var minionsKilled:Int = 0
    ///
    var neutralMinionsKilled:Int = 0
    ///
    var neutralMinionsKilledEnemyJungle:Int = 0
    ///
    var neutralMinionsKilledYourJungle:Int = 0
    /// Flag specifying if the summoner got the killing blow on the nexus.
    var nexusKilled = false
    ///
    var nodeCapture:Int = 0
    ///
    var nodeCaptureAssist:Int = 0
    ///
    var nodeNeutralize:Int = 0
    ///
    var nodeNeutralizeAssist:Int = 0
    ///
    var numDeaths:Int = 0
    ///
    var numItemsBought:Int = 0
    ///
    var objectivePlayerScore:Int = 0
    ///
    var pentaKills:Int = 0
    ///
    var physicalDamageDealtPlayer:Int = 0
    ///
    var physicalDamageDealtToChampions:Int = 0
    ///
    var physicalDamageTaken:Int = 0
    /// Player position (Legal values: TOP(1), MIDDLE(2), JUNGLE(3), BOT(4))
    var playerPosition:Int = 0
    /// Player role (Legal values: DUO(1), SUPPORT(2), CARRY(3), SOLO(4))
    var playerRole:Int = 0
    ///
    var playerScore0:Int = 0
    ///
    var playerScore1:Int = 0
    ///
    var playerScore2:Int = 0
    ///
    var playerScore3:Int = 0
    ///
    var playerScore4:Int = 0
    ///
    var playerScore5:Int = 0
    ///
    var playerScore6:Int = 0
    ///
    var playerScore7:Int = 0
    ///
    var playerScore8:Int = 0
    ///
    var playerScore9:Int = 0
    ///
    var quadraKills:Int = 0
    ///
    var sightWardsBought:Int = 0
    /// Number of times first champion spell was cast.
    var spell1Cast:Int = 0
    /// Number of times second champion spell was cast.
    var spell2Cast:Int = 0
    /// Number of times third champion spell was cast.
    var spell3Cast:Int = 0
    /// Number of times fourth champion spell was cast.
    var spell4Cast:Int = 0
    ///
    var summonSpell1Cast:Int = 0
    ///
    var summonSpell2Cast:Int = 0
    ///
    var superMonsterKilled:Int = 0
    ///
    var team:Int = 0
    ///
    var teamObjective:Int = 0
    ///
    var timePlayed:Int = 0
    ///
    var totalDamageDealt:Int = 0
    ///
    var totalDamageDealtToChampions:Int = 0
    ///
    var totalDamageTaken:Int = 0
    ///
    var totalHeal:Int = 0
    ///
    var totalPlayerScore:Int = 0
    ///
    var totalScoreRank:Int = 0
    ///
    var totalTimeCrowdControlDealt:Int = 0
    ///
    var totalUnitsHealed:Int = 0
    ///
    var tripleKills:Int = 0
    ///
    var trueDamageDealtPlayer:Int = 0
    ///
    var trueDamageDealtToChampions:Int = 0
    ///
    var trueDamageTaken:Int = 0
    ///
    var turretsKilled:Int = 0
    ///
    var unrealKills:Int = 0
    ///
    var victoryPointTotal:Int = 0
    ///
    var visionWardsBought:Int = 0
    ///
    var wardKilled:Int = 0
    ///
    var wardPlaced:Int = 0
    /// Flag specifying whether or not this game was won.
    var win = false
}
