//
//  ChampionDetail_Content_Header.swift
//  Info Center for League of Legends
//
//  Created by Victor Ilisei on 1/5/17.
//  Copyright © 2017 Tech Genius. All rights reserved.
//

import UIKit

protocol ChampViewHeaderDelegate {
    func goBack()
}

class ChampionDetail_Content_Header: UICollectionReusableView {
    var delegate:ChampViewHeaderDelegate?
    
    @IBAction func backButtonpressed() {
        self.delegate?.goBack()
    }
}
