//
//  RecommendedDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class RecommendedDto: NSObject {
    var block = [BlockDto]()
    var champion:String = ""
    var map:String = ""
    var mode:String = ""
    var priority:Bool = false
    var title:String = ""
    var type:String = ""
}
