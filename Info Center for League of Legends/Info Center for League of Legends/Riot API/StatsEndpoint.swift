//
//  StatsEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/14/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class StatsEndpoint: NSObject {
    func getStatsSummaryBySummonerId(summonerId: CLong, completion: (summaryList: PlayerStatsSummaryListDto) -> Void, errorBlock: () -> Void) {
        Endpoints().stats_bySummoner_summary(summonerId: String(summonerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let json = responseObject as! NSDictionary
                })
            }, failure: { (task, error) in
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
