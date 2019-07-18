//
//  HobbyEvent.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 13/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

struct HobbyEventData : Codable {
    let name : String?
    let day_of_week : String?
    let location : String?
    let image : String?
    
    enum CodingKeys: String, CodingKey {
        
        case name = "name"
        case day_of_week = "day_of_week"
        case location = "location"
        case image = "cover_image"
    }
}

