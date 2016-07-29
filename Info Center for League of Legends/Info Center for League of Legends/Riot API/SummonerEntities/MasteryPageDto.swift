//
//  MasteryPageDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class MasteryPageDto: NSObject {
    /// Indicates if the mastery page is the current mastery page.
    var current = false
    /// Mastery page ID.
    var masteryPageId:CLong = 0
    /// Collection of masteries associated with the mastery page.
    var masteries = [MasteryDto]()
    /// Mastery page name.
    var name = ""
}
