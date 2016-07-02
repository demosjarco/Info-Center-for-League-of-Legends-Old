//
//  LeagueEntryDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/2/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class LeagueEntryDto: NSObject {
    var division: String = ""
    var isFreshBlood: Bool = false
    var isHotStreak: Bool = false
    var isInactive: Bool = false
    var isVeteran: Bool = false
    var leaguePoints: Int = 0
    var losses: Int = 0
    var miniSeries: MiniSeriesDto?
    var playerOrTeamId: String = ""
    var playerOrTeamName: String = ""
    var wins: Int = 0
}
