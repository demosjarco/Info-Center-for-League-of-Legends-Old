//
//  RuneDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class RuneDto: NSObject {
//    var colloq = ""
//    var consumeOnFull = false
//    var consumed = false
//    var depth:Int = 0
    var runeDescription = ""
//    var from = [String]()
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
