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
    func getAllShards(completion: @escaping (shards: [Shard]) -> Void, errorBlock: @escaping () -> Void) {
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
                completion(shardArray)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getShardStatus(completion: @escaping (shardStatus: ShardStatus) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().status_byShard { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let shardStatus = ShardStatus()
                
                shardStatus.hostname = json["hostname"] as! String
                shardStatus.locales = json["locales"] as! [String]
                shardStatus.name = json["name"] as! String
                shardStatus.region_tag = json["region_tag"] as! String
                let oldServices = json["services"] as! [[String: AnyObject]]
                for oldService in oldServices {
                    let newService = Service()
                    
                    let oldIncidents = oldService["incidents"] as! [[String: AnyObject]]
                    for oldIncident in oldIncidents {
                        let newIncident = Incident()
                        
                        newIncident.active = oldIncident["active"] as! Bool
                        autoreleasepool(invoking: { ()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                            newIncident.created_at = dateFormatter.date(from: oldIncident["created_at"] as! String)!
                        })
                        newIncident.incidentId = oldIncident["id"] as! CLong
                        let oldUpdates = oldIncident["updates"] as! [[String: AnyObject]]
                        for oldMessage in oldUpdates {
                            let newMessage = Message()
                            
                            newMessage.author = oldMessage["author"] as! String
                            newMessage.content = oldMessage["content"] as! String
                            autoreleasepool(invoking: { ()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                                newMessage.created_at = dateFormatter.date(from: oldMessage["created_at"] as! String)!
                            })
                            newMessage.messageId = oldMessage["id"] as! String
                            newMessage.severity = oldMessage["severity"] as! String
                            let oldTranslations = oldMessage["translations"] as! [[String: AnyObject]]
                            for oldTranslation in oldTranslations {
                                let newTranslation = Translation()
                                
                                newTranslation.content = oldTranslation["content"] as! String
                                newTranslation.locale = oldTranslation["locale"] as! String
                                /*autoreleasepool(invoking: { ()
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                                    newTranslation.updated_at = dateFormatter.date(from: oldTranslation["updated_at"] as! String)!
                                })*/
                                newTranslation.heading = oldTranslation["heading"] as! String
                                
                                newMessage.translations.append(newTranslation)
                            }
                            autoreleasepool(invoking: { ()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                                newMessage.updated_at = dateFormatter.date(from: oldMessage["updated_at"] as! String)!
                            })
                            
                            newIncident.updates.append(newMessage)
                        }
                        
                        newService.incidents.append(newIncident)
                    }
                    newService.name = oldService["name"] as! String
                    newService.slug = oldService["slug"] as! String
                    newService.status = oldService["status"] as! String
                    
                    shardStatus.services.append(newService)
                }
                shardStatus.slug = json["slug"] as! String
                
                completion(shardStatus)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
