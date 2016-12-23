//
//  BasicDataDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class BasicDataDto: NSObject {
//    var colloq = ""
//    var consumeOnFull = false
//    var consumed = false
//    var depth:Int = 0
    var runeDescription = ""
//    var from = [String]()
    /// Data Dragon includes the gold field for basic data, which is shared by both rune and item. However, only items have a gold field on them, representing their gold cost in the store. Since runes are not sold in the store, they have no gold cost.
//    var gold = GoldDto()
//    var group = ""
//    var hideFromAll = false
    var runeId:Int = 0
    var image = ImageDto()
//    var inStore = false
//    var into = [String]()
//    var maps = [String:Bool]()
    var name = ""
//    var plaintext = ""
//    var requiredChampion = ""
    var rune = MetaDataDto()
    var sanitizedDescription = ""
//    var specialRecipe:Int = 0
//    var stacks:Int = 0
    var stats = BasicDataStatsDto()
    var tags = [String]()
}
