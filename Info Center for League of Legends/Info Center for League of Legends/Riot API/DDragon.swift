//
//  DDragon.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 6/25/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import AFNetworking

class DDragon: NSObject {
    func getCDNurl(completion: (cdnUrl: String) -> Void) {
        AFHTTPSessionManager().get("http://ddragon.leagueoflegends.com/realms/" + Endpoints().getRegion() + ".json", parameters: nil, progress: nil, success: { (task, responseObject) in
            let dict = responseObject as! NSDictionary
            completion(cdnUrl: dict["cdn"] as! String)
        }, failure: nil)
    }
    
    func getLatestDDragonVersion(dataType: String, completion: (version: String) -> Void) {
        AFHTTPSessionManager().get("http://ddragon.leagueoflegends.com/realms/" + Endpoints().getRegion() + ".json", parameters: nil, progress: nil, success: { (task, responseObject) in
            let dict = responseObject as! NSDictionary
            completion(version: dict["n"]![dataType] as! String)
        }, failure: nil)
    }
    
    func getProfileIcon(profileIconId: Int, completion: (profileIconURL: URL) -> Void) {
        self.getCDNurl { (cdnUrl) in
            self.getLatestDDragonVersion(dataType: "profileicon", completion: { (version) in
                completion(profileIconURL: URL(string: cdnUrl + "/" + version + "/img/profileicon/" + String(profileIconId) + ".png")!)
            })
        }
    }
            })
        }
    }
}
