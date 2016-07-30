//
//  StaticDataEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/30/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class StaticDataEndpoint: NSObject {
    enum champData:String {
        case All = "all"
        case AllyTips = "allytips"
        case AltImages = "altimages"
        case Blurb = "blurb"
        case EnemyTips = "enemytips"
        case Image = "image"
        case Info = "info"
        case Lore = "lore"
        case Partype = "partype"
        case Passive = "passive"
        case RecommendedItems = "recommended"
        case Skins = "skins"
        case Spells = "spells"
        case Stats = "stats"
        case Tags = "tags"
    }
    
    func getChampionInfoById(champId: Int, championData: champData, completion: () -> Void, notFound: () -> Void, error: () -> Void) {
        Endpoints().staticData_champion_id(championId: String(champId), champData: championData.rawValue) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let json = responseObject as! [String: AnyObject]
                })
            }, failure: { (task, error) in
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
    
    func getRegionValidLocales(completion: (languages: [String]) -> Void) {
        Endpoints().staticData_languages { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                autoreleasepool({ ()
                    let json = responseObject as! [String]
                    completion(languages: json)
                })
            }, failure: { (task, error) in
                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
            })
        }
    }
}
