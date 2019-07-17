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
    
    func setHobbyEvents(hobbyEvent: HobbyEvent) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    
        hobbyImage.image = UIImage(named: "ecology-2985781_640")
        title.text = hobbyEvent.name
        location.text = hobbyEvent.info
        date.text = formatter.string(from: hobbyEvent.startDate)
        icon.image = UIImage(named: "date_range")
    }
    
    
    
 /*   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
 */

}
