//
//  ShardStatus.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ShardStatus: NSObject {
    var hostname:String = ""
    var locales = [String]()
    var name:String = ""
    var region_tag:String = ""
    var services = [Service]()
    var slug:String = ""
}
