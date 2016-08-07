//
//  SC_MasteryDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/6/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class SC_MasteryDto: NSObject {
    var masteryDescription = [String]()
    var masteryId:Int = 0
    var image:ImageDto?
    /// Legal values: Cunning, Ferocity, Resolve
    var masteryTree:String?
    var name:String = ""
    var prereq:String?
    var ranks:Int?
    var sanitizedDescription:String?
}
