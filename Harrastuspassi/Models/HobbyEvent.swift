//
//  HobbyEvent.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 13/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

struct HobbyEventData: Codable {
    let name: String
    let location: Int
    let image: URL?
    
    let dayOfWeek: Int
    
    private enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case name, location, image
    }
    
}



class HobbyEvent {
    
    //MARK: Properties
    
    var name: String
    var imageUrl: URL?
    var startDate: Date
    //var endDate: Date
    var placeholderImage: UIImage?
    var info: String
    
    init(_ name:String = "Placeholder", _ imageUrl:URL? = nil) {
        self.name = name
        if let url = imageUrl {
            self.imageUrl = url;
        } else {
            placeholderImage = UIImage(named: "ecology-2985781_640")
        }
        startDate = Date()
        //endDate = Date()
        info  = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas placerat ipsum id lacus tempus, eget scelerisque est egestas. Aliquam aliquet, odio a ultrices congue, metus lorem scelerisque tellus, ut sodales libero ante et odio. Nullam pulvinar mi sed nisi posuere fringilla et eget nulla. Sed viverra lacus ac erat iaculis varius. Praesent commodo viverra odio eu interdum. Duis eu finibus nisi. Pellentesque bibendum libero non justo placerat fermentum."
    }
 
}
