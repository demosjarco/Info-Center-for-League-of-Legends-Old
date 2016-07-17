//
//  News.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/16/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import SGSStaggeredFlowLayout
import Firebase
import AFNetworking

class News: MainCollectionViewController, UICollectionViewDelegateFlowLayout {
    var entries = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoreleasepool { ()
            let flowLayout = SGSStaggeredFlowLayout()
            flowLayout.layoutMode = SGSStaggeredFlowLayoutMode_Even
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.itemSize = CGSize(width: 256, height: 256)
            
            self.collectionView?.collectionViewLayout = flowLayout
        }
        
        autoreleasepool { ()
            let refresher = UIRefreshControl(frame: self.collectionView!.frame)
            refresher.tintColor = UIColor.lightText()
            refresher.addTarget(self, action: #selector(News.refresh), for: .valueChanged)
            self.collectionView?.insertSubview(refresher, at: self.collectionView!.subviews.count - 1)
            
            self.refresh(sender: refresher)
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
            self.collectionView?.contentOffset = CGPoint(x: 0, y: -sender.frame.size.height)
        }) { (finished: Bool) in
            if !sender.isRefreshing {
                sender.beginRefreshing()
            }
        }
        
        FIRDatabase.database().reference().child("news_languages").observe(FIRDataEventType.value, with: { (snapshot) in
            let languages = snapshot.value as! [String: AnyObject]
            let languagesForRegion = languages[Endpoints().getRegion()] as! [String]
            
            let baseUrl = languages["baseUrl"] as! NSString
            var rssUrl = NSString()
            if languagesForRegion.contains(Locale.preferredLanguages[0].components(separatedBy: "-")[0]) {
                rssUrl = NSString(format: baseUrl, Endpoints().getRegion(), Locale.preferredLanguages[0].components(separatedBy: "-")[0])
            } else {
                rssUrl = NSString(format: baseUrl, Endpoints().getRegion(), languagesForRegion[0])
            }
            rssUrl = rssUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: ":", with: "%3A")
            
            let convertUrl = languages["rssToJsonUrl"] as! NSString
            let url = NSString(format: convertUrl, rssUrl) as String
            
            AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                let json = responseObject as! [String: AnyObject]
                if json["status"] as! String == "ok" {
                    if json["feed"]?["title"] != nil {
                        let feed = json["feed"] as! [String: String]
                        let title = feed["title"]
                        self.title = title
                        self.tabBarItem.title = title
                    }
                    self.entries = json["items"] as! [[String: AnyObject]]
                } else {
                    FIRDatabase.database().reference().child("news_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "errorMessage": json["errorMessage"] as! String, "url": url, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                }
                self.collectionView?.reloadSections(IndexSet(integer: 0))
                sender.endRefreshing()
            }, failure: { (task, error) in
                FIRDatabase.database().reference().child("news_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]!.statusCode, "url": url, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                sender.endRefreshing()
            })
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.entries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
        
        let img1 = self.entries[indexPath.row]["content"] as! String
        let img2 = img1.components(separatedBy: "src=\"").last?.components(separatedBy: "\"")
        var imageUrl:URL?
        autoreleasepool { ()
            var components = URLComponents(string: img2!.first!)
            components?.scheme = "https"
            imageUrl = components?.url
        }
        
        UIImageView().setImageWith(URLRequest(url: imageUrl!), placeholderImage: nil, success: { (request, response, image) in
            
        }) { (request, response, error) in
            
        }
        
        // Configure the cell
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: AnyObject?) {
     
     }
     */
}
