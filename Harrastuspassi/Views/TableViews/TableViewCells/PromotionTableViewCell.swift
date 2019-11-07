//
//  PromotionTableViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class PromotionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var promotionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.layer.cornerRadius = 15;
        cardView.layer.masksToBounds = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setPromotion(_ promotion: PromotionData) {
        titleLabel.text = promotion.name;
        descriptionLabel.text = promotion.description;
        if let image = promotion.image {
            promotionImage.kf.setImage(with: URL(string: image)!);
        } else {
            promotionImage.image = UIImage(named: "logo_lil_yel");
        }
    }
    
}
