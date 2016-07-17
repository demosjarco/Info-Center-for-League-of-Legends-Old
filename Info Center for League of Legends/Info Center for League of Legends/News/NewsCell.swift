//
//  NewsCell.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/17/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class NewsCell: UICollectionViewCell {
    @IBOutlet var newsStoryImage: UIImageView?
    @IBOutlet var newsStoryImageBlur: UIVisualEffectView?
    @IBOutlet var newsStoryBlurTitle: UILabel?
    @IBOutlet var newsStoryBlurContent: UILabel?
    
    @IBOutlet var newsStoryTitle: UILabel?
    @IBOutlet var newsStoryContent: UILabel?
}
