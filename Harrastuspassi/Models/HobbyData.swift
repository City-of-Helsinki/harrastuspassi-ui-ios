//
//  HobbyData.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 26/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct HobbyData: Codable {
    
    let id : Int?
    let name : String?
    let image : String?
    let location : LocationData?
    let category : Int?
    let description : String?
    let organizer : Organizer?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case image = "cover_image"
        case location = "location"
        case category = "category"
        case description = "description"
        case organizer = "organizer"
    }
}

struct Organizer: Codable {
    
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
    }
}
