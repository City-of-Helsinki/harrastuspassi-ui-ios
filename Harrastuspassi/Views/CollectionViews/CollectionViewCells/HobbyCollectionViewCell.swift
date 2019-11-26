//
//  HobbyCollectionViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 21.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class HobbyCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.layer.cornerRadius = 15;
        self.contentView.layer.masksToBounds = true;
    }
    
    func setHobby(_ hobbyEvent: HobbyEventData) {
        if let image = hobbyEvent.hobby?.image {
            imageView.kf.setImage(with: URL(string: image));
        } else {
            imageView.image = UIImage(named: "logo_lil_yel")
        }
        if let hobby = hobbyEvent.hobby {
            titleLabel.text = hobby.name;
            descriptionLabel.text = hobby.description;
            dateLabel.text = "";
        }
    }
    
}
