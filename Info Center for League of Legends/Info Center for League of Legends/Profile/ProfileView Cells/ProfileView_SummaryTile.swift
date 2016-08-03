//
//  ProfileView_SummaryTile.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 7/21/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class ProfileView_SummaryTile: UICollectionViewCell {
    func setupCell() {
        // Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.75
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}
