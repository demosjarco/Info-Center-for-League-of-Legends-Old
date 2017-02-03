//
//  ChampionEndpoint.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/2/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class ChampionEndpoint: NSObject {
    func getAllChampions(_ freeToPlay: Bool, completion: @escaping (_ championList: ChampionListDto) -> Void, errorBlock: @escaping () -> Void) {
        Endpoints().champions(freeToPlay ? "true" : "false") { (composedUrl) in
            autoreleasepool(invoking: { ()
                DispatchQueue.main.async { [unowned self] in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                
                URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URL(string: composedUrl)!, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async { [unowned self] in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    }
                    
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [unowned self] in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let data = data {
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: [[String: AnyObject]]] {
                                            let newChampionList = ChampionListDto()
                                            
                                            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                                            let c_list_entity = NSEntityDescription.entity(forEntityName: "C_1_2_List", in: managedContext)
                                            let c_list = NSManagedObject(entity: c_list_entity!, insertInto: managedContext)
                                            
                                            let oldChampions = json["champions"]!
                                            for oldChampion in oldChampions {
                                                autoreleasepool { ()
                                                    let newChampion = ChampionInfoDto()
                                                    
                                                    let c_info_entity = NSEntityDescription.entity(forEntityName: "C_1_2_Info", in: managedContext)
                                                    let c_info = NSManagedObject(entity: c_info_entity!, insertInto: managedContext)
                                                    
                                                    newChampion.active = oldChampion["active"] as! Bool
                                                    c_info.setValue(oldChampion["active"] as! Bool, forKey: "active")
                                                    newChampion.botEnabled = oldChampion["botEnabled"] as! Bool
                                                    c_info.setValue(oldChampion["botEnabled"] as! Bool, forKey: "botEnabled")
                                                    newChampion.botMmEnabled = oldChampion["botMmEnabled"] as! Bool
                                                    c_info.setValue(oldChampion["botMmEnabled"] as! Bool, forKey: "botMmEnabled")
                                                    newChampion.freeToPlay = oldChampion["freeToPlay"] as! Bool
                                                    c_info.setValue(oldChampion["freeToPlay"] as! Bool, forKey: "freeToPlay")
                                                    newChampion.champId = oldChampion["id"] as! CLong
                                                    c_info.setValue(oldChampion["id"] as! Int32, forKey: "champId")
                                                    newChampion.rankedPlayEnabled = oldChampion["rankedPlayEnabled"] as! Bool
                                                    c_info.setValue(oldChampion["rankedPlayEnabled"] as! Bool, forKey: "rankedPlayEnabled")
                                                    
                                                    newChampionList.champions.append(newChampion)
                                                    c_list.setValue(c_info, forKey: "champInfo")
                                                }
                                            }
                                            
                                            do {
                                                try managedContext.save()
                                            } catch let saveError as NSError {
                                                print("Error saving to core data: \(saveError.localizedDescription)")
                                            }
                                            completion(newChampionList)
                                        }
                                    } catch let jsonError as NSError {
                                        print("Error parsing results: \(jsonError.localizedDescription)")
                                    }
                                }
                            } else {
                                FIRDatabase.database().reference().child("api_error").childByAutoId().updateChildValues(["datestamp": Date().timeIntervalSince1970, "httpCode": httpResponse.statusCode, "url": composedUrl, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                            }
                        }
                    }
                }).resume()
            })
        }
    }
}
