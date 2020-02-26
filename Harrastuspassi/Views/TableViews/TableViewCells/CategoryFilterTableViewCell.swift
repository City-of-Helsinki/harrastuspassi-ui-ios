//
//  CategoryFilterTableViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 09/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CategoryFilterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var categoryData: CategoryData?
    var categorySelected = false
    var selectionDelegate: SelectionDelegate?
    
    func setCategory(category: CategoryData) {
        self.categoryData = category
        if let title = category.name {
            titleLabel.text = title;
        } else {
            titleLabel.text = "Muut";
        }
        checkmarkButton.setImage(UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if categorySelected {
            checkmarkButton.alpha = 1
            checkmarkButton.tintColor = .green
        } else {
            checkmarkButton.alpha = 0.3
            checkmarkButton.tintColor = .black
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkButton.setImage(UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if categorySelected {
            checkmarkButton.alpha = 1
            checkmarkButton.tintColor = .green
        } else {
            checkmarkButton.alpha = 0.3
            checkmarkButton.tintColor = .black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func checkmarkButtonPressed(_ sender: Any) {
        print("checkmarkButton pressed")
        guard let data = categoryData else {
            return
        }
        
        if !categorySelected {
            self.selectionDelegate?.addSelection(selectedItem: data)
            categorySelected = true
            checkmarkButton.alpha = 1
            checkmarkButton.tintColor = .green
        } else {
            self.selectionDelegate?.removeSelection(removedItem: data)
            categorySelected = false
            checkmarkButton.alpha = 0.3
            checkmarkButton.tintColor = .black
        }
        
    }
}
