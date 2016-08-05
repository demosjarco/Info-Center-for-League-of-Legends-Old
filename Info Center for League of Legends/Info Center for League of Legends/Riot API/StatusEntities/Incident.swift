//
//  Incident.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Incident: NSObject {
    var active:Bool = false
    var created_at = Date()
    var incidentId:CLong = 0
    var updates = [Message]()
}
