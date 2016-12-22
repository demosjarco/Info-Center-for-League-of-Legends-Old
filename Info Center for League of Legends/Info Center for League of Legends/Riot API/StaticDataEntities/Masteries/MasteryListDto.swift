//
//  MasteryListDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/6/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class MasteryListDto: NSObject {
    var data = [String: SC_MasteryDto]()
    var tree:MasteryTreeDto?
    var type:String = ""
    var version:String = ""
}
