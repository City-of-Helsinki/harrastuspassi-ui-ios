//
//  PromotionTableViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import Kingfisher

class PromotionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var promotionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cardView: UIView!

    
    func setUsedAppearance() {
        cardView.layer.opacity = 0.2;
    }
    
    func setUnUsedAppearence() {
        cardView.layer.opacity = 1
    }

    func setPromotion(_ promotion: PromotionData) {
        cardView.layer.cornerRadius = 15;
        cardView.layer.masksToBounds = true;
        titleLabel.text = promotion.name;
        descriptionLabel.text = promotion.description;
        dateLabel.text = String(format: NSLocalizedString("ValidUntil", comment: ""), Utils.formatDateFromString(promotion.endDate));
        let placeholderImage = UIImage(named: "logo_lil_yel");
        if let image = promotion.image {
        
            promotionImage.kf.indicatorType = .activity;
            promotionImage.kf.setImage(with: URL(string: image)!, placeholder: placeholderImage) { _ in
                self.setNeedsLayout()
                self.layoutIfNeeded()
            };
        } else {
            promotionImage.image = placeholderImage;
        }
    }
    
}
