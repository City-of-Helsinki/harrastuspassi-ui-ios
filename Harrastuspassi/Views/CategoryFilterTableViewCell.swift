//
//  CategoryFilterTableViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 09/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CategoryFilterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setCategory(category: CategoryData) {
        if let title = category.name {
            titleLabel.text = title;
        } else {
            titleLabel.text = "Muut";
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
