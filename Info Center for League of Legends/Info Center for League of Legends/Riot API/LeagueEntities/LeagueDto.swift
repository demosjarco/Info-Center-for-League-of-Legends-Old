//
//  LeagueDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/2/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class LeagueDto: NSObject {
    var entries: [LeagueEntryDto] = [LeagueEntryDto]()
    var name: String = ""
    var participantId: String?
    var queue: String = ""
    var tier: String = ""
}
