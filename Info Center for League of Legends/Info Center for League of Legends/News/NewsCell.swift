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
            let _gradientLayer = CAGradientLayer()
            _gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main().bounds.size.width, height: 256)
            _gradientLayer.colors = [UIColor.clear().cgColor, UIColor.black().cgColor]
            _gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            _gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.7)
            let _maskingLayer = CALayer()
            _maskingLayer.frame = CGRect(origin: CGPoint.zero, size: _gradientLayer.frame.size)
            _maskingLayer.addSublayer(_gradientLayer)
            self.newsStoryImageBlur?.layer.mask = _maskingLayer
        }
        self.newsStoryImageBlur?.setNeedsDisplay()
        
        self.newsStoryTitle?.isHidden = true
        self.newsStoryTitle?.setNeedsDisplay()
        
        self.newsStoryContent?.isHidden = true
        self.newsStoryContent?.setNeedsDisplay()
    }
}
