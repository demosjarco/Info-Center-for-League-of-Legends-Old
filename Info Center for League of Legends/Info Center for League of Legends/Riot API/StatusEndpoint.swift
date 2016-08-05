//
//  StatusEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 8/5/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class StatusEndpoint: NSObject {
    func getAllShards(completion: (shards: [Shard]) -> Void, error: () -> Void) {
        Endpoints().status_shards { (composedUrl) in
            AFHTTPSessionManager()
        }
    }
    
    func getShardStatus(completion: (shardStatus: ShardStatus) -> Void, error: () -> Void) {
        Endpoints().status_byShard { (composedUrl) in
            AFHTTPSessionManager()
        }
    }
}
