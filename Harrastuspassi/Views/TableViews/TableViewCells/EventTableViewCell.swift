//
//  EventTableViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 01/10/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
