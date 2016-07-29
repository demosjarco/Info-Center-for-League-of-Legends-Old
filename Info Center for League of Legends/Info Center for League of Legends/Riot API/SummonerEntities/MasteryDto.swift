//
//  MasteryDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class MasteryDto: NSObject {
    /// Mastery ID. For static information correlating to masteries, please refer to the LoL Static Data API.
    var masteryId:Int = 0
    /// Mastery rank (i.e., the number of points put into this mastery).
    var rank:Int = 0
}
