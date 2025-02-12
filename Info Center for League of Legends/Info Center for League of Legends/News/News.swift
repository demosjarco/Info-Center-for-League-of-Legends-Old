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
import SafariServices

class News: MainCollectionViewController, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate {
    let MAX_CELL_SIZE = 256
    var entries = [[String: AnyObject]]()
    var screenSizeLeftHorizontal = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoreleasepool { ()
            let flowLayout = SGSStaggeredFlowLayout()
            flowLayout.layoutMode = SGSStaggeredFlowLayoutMode_Centered
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.itemSize = CGSize(width: MAX_CELL_SIZE, height: MAX_CELL_SIZE)
            
            self.collectionView?.setCollectionViewLayout(flowLayout, animated: true)
            
            let refresher = UIRefreshControl(frame: self.collectionView!.frame)
            refresher.tintColor = UIColor.lightText
            refresher.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
            self.collectionView?.insertSubview(refresher, at: self.collectionView!.subviews.count - 1)
            
            self.refresh(refresher)
        }
    }
    
    func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.collectionView?.contentOffset = CGPoint(x: 0, y: -sender.frame.size.height)
            }, completion: nil)
            sender.beginRefreshing()
        }
        
        FIRDatabase.database().reference().child("news_languages").observe(FIRDataEventType.value, with: { (snapshot) in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [unowned self] in
                autoreleasepool(invoking: { ()
                    let languages = snapshot.value as! [String: AnyObject]
                    let languagesForRegion = languages[Endpoints().getRegion()] as! [String]
                    
                    let baseUrl = languages["baseUrl"] as! NSString
                    var rssUrl = NSString()
                    if languagesForRegion.contains(Locale.preferredLanguages[0].components(separatedBy: "-")[0]) {
                        rssUrl = NSString(format: baseUrl, Endpoints().getRegion(), Locale.preferredLanguages[0].components(separatedBy: "-")[0])
                    } else {
                        rssUrl = NSString(format: baseUrl, Endpoints().getRegion(), languagesForRegion[0])
                    }
                    rssUrl = rssUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: ":", with: "%3A") as NSString
                    
                    let url = String(format: languages["rssToJsonUrl"] as! String, rssUrl)
                    
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { [unowned self] in
                            autoreleasepool(invoking: { ()
                                let json = responseObject as! [String: AnyObject]
                                if json["status"] as! String == "ok" {
                                    if json["feed"]?["title"] != nil {
                                        let feed = json["feed"] as! [String: String]
                                        let title = feed["title"]
                                        DispatchQueue.main.async { [unowned self] in
                                            self.title = title
                                            self.tabBarItem.title = title
                                        }
                                    }
                                    self.entries = json["items"] as! [[String: AnyObject]]
                                } else {
                                    FIRDatabase.database().reference().child("news_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "errorMessage": json["errorMessage"] as! String, "url": url, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                                }
                                
                                DispatchQueue.main.async { [unowned self] in
                                    self.collectionView?.reloadSections(IndexSet(integer: 0))
                                    sender.endRefreshing()
                                }
                            })
                        }
                    }, failure: { (task, error) in
                        let response = task!.response as! HTTPURLResponse
                        FIRDatabase.database().reference().child("news_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": url, "deviceModel": Endpoints().getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                        DispatchQueue.main.async { [unowned self] in
                            sender.endRefreshing()
                        }
                    })
                })
            }
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        autoreleasepool { ()
            let flowLayout = SGSStaggeredFlowLayout()
            flowLayout.layoutMode = SGSStaggeredFlowLayoutMode_Centered
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.itemSize = CGSize(width: MAX_CELL_SIZE, height: MAX_CELL_SIZE)
            
            self.collectionView?.setCollectionViewLayout(flowLayout, animated: true)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.frame.size.width >= CGFloat(MAX_CELL_SIZE * 2) {
            if screenSizeLeftHorizontal < CGFloat(MAX_CELL_SIZE) {
                screenSizeLeftHorizontal = collectionView.frame.size.width
            }
            
            let maxColums = Int(floor(screenSizeLeftHorizontal / CGFloat(MAX_CELL_SIZE)))
            let random = Int(arc4random_uniform(UInt32(maxColums - 1))) + 1
            screenSizeLeftHorizontal -= CGFloat(MAX_CELL_SIZE * random)
            
            return CGSize(width: MAX_CELL_SIZE * random, height: MAX_CELL_SIZE)
        }
        return CGSize(width: collectionView.frame.size.width, height: CGFloat(MAX_CELL_SIZE))
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCell
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.layer.shouldRasterize = true
        
        cell.newsStoryImage?.image = nil
        cell.newsStoryImageForBlur?.image = nil
        
        autoreleasepool { ()
            let img1 = self.entries[indexPath.row]["content"] as! String
            let img2 = img1.components(separatedBy: "src=\"").last?.components(separatedBy: "\"")
            var components = URLComponents(string: img2!.first!)
            components?.scheme = "https"
            let imageUrl = components?.url
            
            cell.newsStoryImage?.setImageWith(URLRequest(url: imageUrl!), placeholderImage: nil, success: { (request, response, image) in
                DispatchQueue.main.async { [unowned self] in
                    cell.setStoryImage(image)
                }
            }, failure: nil)
            
            cell.newsStoryBlurTitle?.text = entries[indexPath.row]["title"] as? String
            cell.newsStoryTitle?.text = entries[indexPath.row]["title"] as? String
            
            let temp = entries[indexPath.row]["content"] as! String
            do {
                try cell.newsStoryBlurContent?.text = NSAttributedString(data: temp.data(using: String.Encoding.utf8)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string
                try cell.newsStoryContent?.text = cell.newsStoryBlurContent?.text
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newsReader = SFSafariViewController(url: URL(string: self.entries[indexPath.row]["link"] as! String)!, entersReaderIfAvailable: false)
        newsReader.delegate = self
        self.present(newsReader, animated: true, completion: {
            collectionView.deselectItem(at: indexPath, animated: true)
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegate
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
