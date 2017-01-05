//
//  ChampionDetail.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/4/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit
import LNPopupController

class ChampionDetail: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ChampViewDelegate {
    var champion = ChampionDto()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoreleasepool { ()
            let content = self.storyboard!.instantiateViewController(withIdentifier: "ChampionDetail_Content") as! ChampionDetail_Content
            content.delegate = self
            content.champion = self.champion
            content.popupItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.closeView))]
            
            // Use the new LCU icon if exists
            if let champIcon = DDragon().getLcuChampionSquareArt(champId: self.champion.champId) {
                content.popupItem.image = champIcon
            } else {
                DDragon().getChampionSquareArt(self.champion.image!.full, completion: { (champSquareArtUrl) in
                    autoreleasepool(invoking: { ()
                        UIImageView().setImageWith(URLRequest(url: champSquareArtUrl), placeholderImage: nil, success: { (request, response, image) in
                            content.popupItem.image = image
                        }, failure: nil)
                    })
                })
            }
            
            content.popupItem.title = self.champion.name
            content.popupItem.subtitle = self.champion.title
            
            self.tabBarController?.presentPopupBar(withContentViewController: content, openPopup: true, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    func goBack() {
        self.closeView()
    }
    
    func closeView() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showSkinPages" {
            let pageViewController = segue.destination as! UIPageViewController
            pageViewController.delegate = self
            pageViewController.dataSource = self
            pageViewController.setViewControllers([viewControllerAtIndex(0)!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        } else if segue.identifier == "" {
            
        }
    }
    
    func viewControllerAtIndex(_ index: Int) -> ChampionDetail_SkinBg? {
        if self.champion.skins!.count == 0 || index >= self.champion.skins!.count {
            return nil
        }
        
        let page = self.storyboard!.instantiateViewController(withIdentifier: "ChampionDetail_SkinBg") as! ChampionDetail_SkinBg
        page.fullImageName = self.champion.image!.full
        page.champId = self.champion.champId
        page.skinNum = self.champion.skins![index].num
        page.pageIndex = index
        
        return page
    }
    
    // MARK: UIPageViewControllerDataSource
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.champion.skins!.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ChampionDetail_SkinBg).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ChampionDetail_SkinBg).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == self.champion.skins!.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    // MARK: UIPageViewControllerDelegate

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

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

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}
