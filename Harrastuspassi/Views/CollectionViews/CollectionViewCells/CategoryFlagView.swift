//
//  CategoryFlagView.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 16/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CategoryFlagView: UICollectionViewCell {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews();
        print("layout cell")
    } 
}
