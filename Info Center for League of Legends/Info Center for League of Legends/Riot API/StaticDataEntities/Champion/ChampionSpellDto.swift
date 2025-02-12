//
//  ChampionSpellDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ChampionSpellDto: NSObject {
    var altimages = [ImageDto]()
    var cooldown = [Double]()
    var cooldownBurn:String = ""
    var cost = [Int]()
    var costBurn:String = ""
    var costType:String = ""
    var rawDescription:String = ""
    /// This field is a List of List of Double.
    var effect = [[Double]()]
    var effectBurn = [String]()
    var image = ImageDto()
    var key:String = ""
    var leveltip = LevelTipDto()
    var maxrank:Int = 0
    var name:String = ""
    /// Range of 0 denotes self
    var range = [Int]()
    var rangeBurn:String = ""
    var resource:String = ""
    var sanitizedDescription:String = ""
    var sanitizedTooltip:String = ""
    var tooltip:String = ""
    var vars = [SpellVarsDto]()
}
