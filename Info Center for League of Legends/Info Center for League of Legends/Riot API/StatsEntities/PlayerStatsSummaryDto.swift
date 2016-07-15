//
//  PlayerStatsSummaryDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class PlayerStatsSummaryDto: NSObject {
    var aggregatedStats = AggregatedStatsDto()
    var losses: Int = 0
    var modifyDate: CLong = 0
    var playerStatSummaryType: String = ""
    var wins: Int = 0
}
