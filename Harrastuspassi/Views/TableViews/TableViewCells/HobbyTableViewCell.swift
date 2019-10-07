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
        
        if let hobby = hobbyEvent.hobby, let imageUrl = hobby.image {
            let url = URL (string: imageUrl)
            hobbyImage.kf.indicatorType = .activity;
            hobbyImage.kf.setImage(with: url!)
        } else {
            hobbyImage.image = UIImage(named: "ic_panorama")
        }
        
        if let hobby = hobbyEvent.hobby, let place = hobby.location?.name {
            location.text = place
        } else {
            location.text = "Ei paikkatietoa"
        }
        
        if let time = hobbyEvent.startDayOfWeek {
            date.text = Weekdays().list.first{ $0.id == time}?.name
        } else {
            date.text = "Ei tapahtuma-aikaa"
        }
        
        title.text = hobbyEvent.hobby?.name
        icon.image = UIImage(named: "date_range")
    }
    
}


