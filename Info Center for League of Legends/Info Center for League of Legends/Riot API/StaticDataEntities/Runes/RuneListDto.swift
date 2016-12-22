//
//  RuneListDto.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/22/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class RuneListDto: NSObject {
    var basic = BasicDataDto()
    var data = [String:RuneDto]()
    var type = ""
    var version = ""
}
