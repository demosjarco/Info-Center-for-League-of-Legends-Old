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
    var cooldownBurn:String
    var cost = [Int]()
    var costBurn:String
    var costType:String
    var description:String
    /// This field is a List of List of Double.
    var effect:[AnyObject]
    var effectBurn = [String]()
    var image = ImageDto()
    var key:String
    var leveltip = LevelTipDto()
    var maxrank:Int
    var name:String
    /// This field is either a List of Integer or the String 'self' for spells that target one's own champion.
    var range:AnyObject
    var rangeBurn:String
    var resource:String
    var sanitizedDescription:String
    var sanitizedTooltip:String
    var tooltip:String
    var vars = [SpellVarsDto]()
}
