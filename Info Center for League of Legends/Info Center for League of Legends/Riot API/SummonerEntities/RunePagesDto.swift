//
//  RunePagesDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class RunePagesDto: NSObject {
    /// Collection of rune pages associated with the summoner.
    var pages = [RunePageDto]()
    /// Summoner ID.
    var summonerId:CLong = 0
}
