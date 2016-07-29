//
//  MasteryPagesDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class MasteryPagesDto: NSObject {
    /// Collection of mastery pages associated with the summoner.
    var pages = [MasteryPageDto]()
    /// Summoner ID.
    var summonerId:CLong = 0
}
