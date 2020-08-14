//
//  LocationTableViewCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 05/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
       
    }

}
