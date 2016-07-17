//
//  NewsCell.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/17/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import QuartzCore

class NewsCell: UICollectionViewCell {
    @IBOutlet var newsStoryImage: UIImageView?
    @IBOutlet var newsStoryImageForBlur: UIImageView?
    @IBOutlet var newsStoryImageBlur: UIView?
    @IBOutlet var newsStoryBlurTitle: UILabel?
    @IBOutlet var newsStoryBlurContent: UILabel?
    
    @IBOutlet var newsStoryTitle: UILabel?
    @IBOutlet var newsStoryContent: UILabel?
    
    func setStoryImage(storyImage: UIImage) {
        self.newsStoryImage?.image = storyImage
        self.newsStoryImageForBlur?.image = storyImage
        self.newsStoryImage?.isHidden = false
        self.newsStoryImage?.setNeedsDisplay()
        
        self.newsStoryImageBlur?.isHidden = false
        // Gradient Mask
        autoreleasepool { ()
            let _maskingImage = UIImage(named: "NewsCellBlurMask")
            let _maskingLayer = CALayer()
            _maskingLayer.frame = CGRect(origin: CGPoint.zero, size: _maskingImage!.size)
            _maskingLayer.contents = _maskingImage?.cgImage
            self.newsStoryImageBlur?.layer.mask = _maskingLayer
        }
        self.newsStoryImageBlur?.setNeedsDisplay()
        
        self.newsStoryTitle?.isHidden = true
        self.newsStoryTitle?.setNeedsDisplay()
        
        self.newsStoryContent?.isHidden = true
        self.newsStoryContent?.setNeedsDisplay()
    }
}
