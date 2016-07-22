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
    var assists:Int?
    /// Number of enemy inhibitors killed.
    var barracksKilled:Int?
    ///
    var bountyLevel:Int?
    ///
    var championsKilled:Int?
    ///
    var combatPlayerScore:Int?
    ///
    var consumablesPurchased:Int?
    ///
    var damageDealtPlayer:Int?
    ///
    var doubleKills:Int?
    ///
    var firstBlood:Int?
    ///
    var gold:Int?
    ///
    var goldEarned:Int?
    ///
    var goldSpent:Int?
    ///
    var item0:Int?
    ///
    var item1:Int?
    ///
    var item2:Int?
    ///
    var item3:Int?
    ///
    var item4:Int?
    ///
    var item5:Int?
    ///
    var item6:Int?
    ///
    var itemsPurchased:Int?
    ///
    var killingSprees:Int?
    ///
    var largestCriticalStrike:Int?
    ///
    var largestKillingSpree:Int?
    ///
    var largestMultiKill:Int?
    /// Number of tier 3 items built.
    var legendaryItemsCreated:Int?
    ///
    var level:Int?
    ///
    var magicDamageDealtPlayer:Int?
    ///
    var magicDamageDealtToChampions:Int?
    ///
    var magicDamageTaken:Int?
    ///
    var minionsDenied:Int?
    ///
    var minionsKilled:Int?
    ///
    var neutralMinionsKilled:Int?
    ///
    var neutralMinionsKilledEnemyJungle:Int?
    ///
    var neutralMinionsKilledYourJungle:Int?
    /// Flag specifying if the summoner got the killing blow on the nexus.
    var nexusKilled:Bool?
    ///
    var nodeCapture:Int?
    ///
    var nodeCaptureAssist:Int?
    ///
    var nodeNeutralize:Int?
    ///
    var nodeNeutralizeAssist:Int?
    ///
    var numDeaths:Int?
    ///
    var numItemsBought:Int?
    ///
    var objectivePlayerScore:Int?
    ///
    var pentaKills:Int?
    ///
    var physicalDamageDealtPlayer:Int?
    ///
    var physicalDamageDealtToChampions:Int?
    ///
    var physicalDamageTaken:Int?
    /// Player position (Legal values: TOP(1), MIDDLE(2), JUNGLE(3), BOT(4))
    var playerPosition:Int?
    /// Player role (Legal values: DUO(1), SUPPORT(2), CARRY(3), SOLO(4))
    var playerRole:Int?
    ///
    var playerScore0:Int?
    ///
    var playerScore1:Int?
    ///
    var playerScore2:Int?
    ///
    var playerScore3:Int?
    ///
    var playerScore4:Int?
    ///
    var playerScore5:Int?
    ///
    var playerScore6:Int?
    ///
    var playerScore7:Int?
    ///
    var playerScore8:Int?
    ///
    var playerScore9:Int?
    ///
    var quadraKills:Int?
    ///
    var sightWardsBought:Int?
    /// Number of times first champion spell was cast.
    var spell1Cast:Int?
    /// Number of times second champion spell was cast.
    var spell2Cast:Int?
    /// Number of times third champion spell was cast.
    var spell3Cast:Int?
    /// Number of times fourth champion spell was cast.
    var spell4Cast:Int?
    ///
    var summonSpell1Cast:Int?
    ///
    var summonSpell2Cast:Int?
    ///
    var superMonsterKilled:Int?
    ///
    var team:Int?
    ///
    var teamObjective:Int?
    ///
    var timePlayed:Int?
    ///
    var totalDamageDealt:Int?
    ///
    var totalDamageDealtToChampions:Int?
    ///
    var totalDamageTaken:Int?
    ///
    var totalHeal:Int?
    ///
    var totalPlayerScore:Int?
    ///
    var totalScoreRank:Int?
    ///
    var totalTimeCrowdControlDealt:Int?
    ///
    var totalUnitsHealed:Int?
    ///
    var tripleKills:Int?
    ///
    var trueDamageDealtPlayer:Int?
    ///
    var trueDamageDealtToChampions:Int?
    ///
    var trueDamageTaken:Int?
    ///
    var turretsKilled:Int?
    ///
    var unrealKills:Int?
    ///
    var victoryPointTotal:Int?
    ///
    var visionWardsBought:Int?
    ///
    var wardKilled:Int?
    ///
    var wardPlaced:Int?
    /// Flag specifying whether or not this game was won.
    var win = false
}
