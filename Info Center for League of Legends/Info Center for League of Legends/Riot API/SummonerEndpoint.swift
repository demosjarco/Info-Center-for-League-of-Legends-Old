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
    func getSummonersForSummonerNames(summonerNames: [String], completion: (summonerMap: [String: SummonerDto]) -> Void) {
        
        // Standardize names
        let standardizedSummonerNames = NSMutableArray()
        for summonerName:String in summonerNames {
            standardizedSummonerNames.add(summonerName.replacingOccurrences(of: " ", with: "").lowercased())
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = Endpoints().summoner_byName(summonerNames: standardizedSummonerNames.value(forKey: "description").componentsJoined(by: ","))
        Endpoints().getApiKey { (apiKey) in
            components.query = "api_key=" + apiKey
            
            
        }
    }
}
