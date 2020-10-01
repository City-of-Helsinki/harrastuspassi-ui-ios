//
//  TableViewCell.swift
//  Harrastuspassi
//
//  Created by Tiia Trogen on 11/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import Kingfisher

class HobbyTableViewCell: UITableViewCell {

    @IBOutlet weak var hobbyImage: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var location: UILabel!
    
    func setHobbyEvents(hobbyEvent: HobbyEventData) {
        
        cardView.layer.cornerRadius = 15
        cardView.layer.masksToBounds = true;
        
        if let hobby = hobbyEvent.hobby, let imageUrl = hobby.image {
            let url = URL (string: imageUrl)
            hobbyImage.kf.indicatorType = .activity;
            hobbyImage.kf.setImage(with: url!)
        } else {
            let image = UIImage(named: "logo_lil_yel");
            hobbyImage.image = image;
        }
        
        if let hobby = hobbyEvent.hobby, let place = hobby.location?.name {
            location.text = place
        } else {
            location.text = "Ei paikkatietoa"
        }
        
        if let time = hobbyEvent.startDate {
            date.text = Utils.formatDateFromString(time)
        } else {
            date.text = "Ei tapahtuma-aikaa"
        }
        
        if let dataSource = hobbyEvent.dataSource {
            if dataSource == "lipas" {
                icon.isHidden = true;
                date.isHidden = true;
            } else {
                icon.isHidden = false;
                date.isHidden = false;
            }
        }
        
        title.text = hobbyEvent.hobby?.name
    }
    
}


