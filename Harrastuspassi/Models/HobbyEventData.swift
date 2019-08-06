//
//  HobbyEvent.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 13/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct HobbyEventData : Codable {
    let id : Int?
    let name : String?
    let startDayOfWeek : String?
    let endDayOfWeek : String?
    let image : String?
    let location : LocationData?
    let category : Int?
    let description : String?
    let startDate : String?
    let endDate: String?
    let createdAt : String?
    let modifiedAt : String?
    let organizer : String?
    let startTime : String?
    let endTime : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case startDayOfWeek = "start_day_of_week"
        case endDayOfWeek = "end_day_of_week"
        case image = "cover_image"
        case location = "location"
        case category = "category"
        case description = "description"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case modifiedAt = "modified_at"
        case organizer = "organizer"
        case endTime = "end_time"
        case startTime = "start_time"
    }
}

