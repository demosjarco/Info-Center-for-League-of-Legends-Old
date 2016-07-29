//
//  SummonerEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/23/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class SummonerEndpoint: NSObject {
    func getSummonersForSummonerNames(summonerNames: [String], completion: (summonerMap: [String: SummonerDto]) -> Void, notFound: () -> Void, errorBlock: () -> Void) {
        // Standardize names
        let standardizedSummonerNames = NSMutableArray()
        for summonerName:String in summonerNames {
            standardizedSummonerNames.add(summonerName.replacingOccurrences(of: " ", with: "").lowercased())
        }
        
        Endpoints().summoner_byName(summonerNames: standardizedSummonerNames.value(forKey: "description").componentsJoined(by: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    var newDict = [String: SummonerDto]()
                    let dict = responseObject as! NSDictionary
                    let dictValues = dict.allValues as! [[String: AnyObject]]
                    for i in 0 ..< dictValues.count {
                        var oldSummoner = dictValues[i]
                        
                        let newSummoner = SummonerDto()
                        newSummoner.summonerId = oldSummoner["id"] as! CLong
                        newSummoner.name = oldSummoner["name"] as! String
                        newSummoner.profileIconId = oldSummoner["profileIconId"] as! Int
                        newSummoner.revisionDate = oldSummoner["revisionDate"] as! CLong
                        newSummoner.summonerLevel = oldSummoner["summonerLevel"] as! CLong
                        
                        newDict[dict.allKeys[i] as! String] = newSummoner
                    }
                    completion(summonerMap: newDict)
                })
            }, failure: { (task, error) in
                if error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode == 404 {
                    notFound()
                } else {
                    errorBlock()
                    FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                }
            })
        }
    }
    
    func getSummonersForIds(summonerIds: [CLong], completion: (summonerMap: [String: SummonerDto]) -> Void, errorBlock: () -> Void) {
        Endpoints().summoner_byId(summonerIds: NSArray(array: summonerIds).value(forKey: "description").componentsJoined(by: ",")) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    var newDict = [String: SummonerDto]()
                    let dict = responseObject as! NSDictionary
                    let dictValues = dict.allValues as! [[String: AnyObject]]
                    for i in 0 ..< dictValues.count {
                        autoreleasepool({ ()
                            let oldSummoner = dictValues[i]
                            
                            let newSummoner = SummonerDto()
                            newSummoner.summonerId = oldSummoner["id"] as! CLong
                            newSummoner.name = oldSummoner["name"] as! String
                            newSummoner.profileIconId = oldSummoner["profileIconId"] as! Int
                            newSummoner.revisionDate = oldSummoner["revisionDate"] as! CLong
                            newSummoner.summonerLevel = oldSummoner["summonerLevel"] as! CLong
                            
                            newDict[dict.allKeys[i] as! String] = newSummoner
                        })
                    }
                    completion(summonerMap: newDict)
                })
            }, failure: { (task, error) in
                errorBlock()
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
