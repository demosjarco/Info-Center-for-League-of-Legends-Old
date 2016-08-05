//
//  Message.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class Message: NSObject {
    var author:String = ""
    var content:String = ""
    var created_at = Date()
    var messageId:String = ""
    var severity:String = ""
    var translations = [Translation]()
    var updated_at = Date()
}
