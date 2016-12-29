//
//  CurrentGameEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 12/29/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import AFNetworking

class CurrentGameEndpoint: NSObject {
    /**
     Get current game information for the given summoner ID.
     */
    func getSpectatorGameInfo(_ summonerId: CLong, completion: @escaping (_ game: CurrentGameInfo) -> Void, notFound: @escaping () -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().currentGame(String(summonerId)) { (composedUrl) in
            AFHTTPSessionManager().get(composedUrl, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                let game = CurrentGameInfo()
                
                completion(game)
            }, failure: { (task, error) in
                let response = task!.response as! HTTPURLResponse
                if response.statusCode == 404 {
                    notFound()
                } else {
                    errorBlock()
                    FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                }
            })
        }
    }
}
