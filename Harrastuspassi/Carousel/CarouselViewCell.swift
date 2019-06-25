//
//  CarouselViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 13/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CarouselViewCell: UITableViewCell {
    
    var data: [HobbyEvent]?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ data:[HobbyEvent]) {
        self.data = data;
        pageControl.numberOfPages = data.count
        pageControl.currentPage = 0
        
    }
    
}

class CarouselViewCard: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
}
