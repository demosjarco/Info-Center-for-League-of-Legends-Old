//
//  ChampionDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ChampionDto: NSObject {
    var allytips:[String]?
    var blurb:String?
    var enemytips:[String]?
    var champId:Int = 0
    var image:ImageDto?
    var info:InfoDto?
    var key:String = ""
    var lore:String?
    var name:String = ""
    var partype:String?
    var passive:PassiveDto?
    var recommended:[RecommendedDto]?
    var skins:[SkinDto]?
    var spells:[ChampionSpellDto]?
    var stats:StatsDto?
    var tags:[String]?
    var title:String = ""
}
