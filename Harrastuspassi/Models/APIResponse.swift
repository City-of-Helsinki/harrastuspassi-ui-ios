//
//  File.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 29.1.2020.
//  Copyright © 2020 Haltu. All rights reserved.
//

import Foundation

struct APIResponse<T>: Codable {
    
    let count : Int?
    let next : String?
    let previous : String?
    let results : [T]?
    
    enum CodingKeys: String, CodingKey {
        
        case count = "id"
        case next = "name"
        case image = "cover_image"
        case location = "location"
    }
    
}
