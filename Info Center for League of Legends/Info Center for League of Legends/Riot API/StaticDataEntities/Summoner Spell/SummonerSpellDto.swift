//
//  SummonerSpellDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/12/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class SummonerSpellDto: NSObject {
    var cooldown:[Double]?
    var cooldownBurn:String?
    var cost:[Int]?
    var costBurn:String?
    var costType:String?
    var spellDescription:String = ""
    /// This field is a List of List of Double.
    var effect:[[Double]]?
    var effectBurn:[String]?
    var spellId:Int = 0
    var image:ImageDto?
    var key:String = ""
    var leveltip:LevelTipDto?
    var maxrank:Int?
    var modes:[String]?
    var name:String = ""
    /// If 0, then spell targets one's own champion.
    var range:[Int]?
    var rangeBurn:String?
    var resource:String?
    var sanitizedDescription:String?
    var sanitizedTooltip:String?
    var summonerLevel:Int = 0
    var tooltip:String?
    var vars:[SpellVarsDto]?
}
