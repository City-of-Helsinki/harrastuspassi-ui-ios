//
//  TableViewCell.swift
//  Harrastuspassi
//
//  Created by Tiia Trogen on 11/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class HobbyTableViewCell: UITableViewCell {

    @IBOutlet weak var hobbyImage: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var location: UILabel!
    
    func setHobbyEvents(hobbyEvent: HobbyEventData) {
        
        if let imageUrl = hobbyEvent.image {
            let url = URL (string: imageUrl)
            hobbyImage.loadurl(url: url!)
        } else {
            hobbyImage.image = UIImage(named: "ic_panorama")
        }
        
        if let place = hobbyEvent.location?.name {
            location.text = place
        } else {
            location.text = "Ei paikkatietoa"
        }
        
        if let time = hobbyEvent.startDayOfWeek {
            date.text = time
        } else {
            date.text = "Ei tapahtuma-aikaa"
        }
        
        title.text = hobbyEvent.name
        icon.image = UIImage(named: "date_range")
    }
}

extension UIImageView {
    func loadurl(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
