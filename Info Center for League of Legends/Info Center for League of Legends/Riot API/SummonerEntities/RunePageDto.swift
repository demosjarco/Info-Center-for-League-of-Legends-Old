//
//  RunePageDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation

class RunePageDto: NSObject {
    /// Indicates if the mastery page is the current mastery page.
    var current = false
    /// Rune page ID.
    var runePageId:CLong = 0
    /// Rune page name.
    var name = ""
    /// Collection of rune slots associated with the rune page.
    var slots = [RuneSlotDto]()
}
