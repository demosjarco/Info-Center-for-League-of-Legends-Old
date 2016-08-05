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
    func getAllShards(completion: (shards: [Shard]) -> Void, errorBlock: () -> Void) {
        Endpoints().status_shards { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [[String: AnyObject]]
                var shardArray = [Shard]()
                for oldShard in json {
                    let newShard = Shard()
                    
                    newShard.hostname = oldShard["hostname"] as! String
                    newShard.locales = oldShard["locales"] as! [String]
                    newShard.name = oldShard["name"] as! String
                    newShard.region_tag = oldShard["region_tag"] as! String
                    newShard.slug = oldShard["slug"] as! String
                    
                    shardArray.append(newShard)
                }
                completion(shards: shardArray)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getShardStatus(completion: (shardStatus: ShardStatus) -> Void, errorBlock: () -> Void) {
        Endpoints().status_byShard { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
