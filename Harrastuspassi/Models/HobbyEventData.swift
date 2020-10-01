//
//  HobbyEvent.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 13/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct HobbyEventData : Codable, Hashable {
    
    
    let id : Int?
    let startDayOfWeek : Int?
    let hobby : HobbyData?
    let startDate : String?
    let endDate: String?
    let startTime : String?
    let endTime : String?
    let dataSource: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hobby?.id);
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case startDayOfWeek = "start_weekday"
        case hobby = "hobby"
        case startDate = "start_date"
        case endDate = "end_date"
        case endTime = "end_time"
        case startTime = "start_time"
        case dataSource = "data_source"
    }
    
    static func == (lhs: HobbyEventData, rhs: HobbyEventData) -> Bool {
        return lhs.hobby?.id == rhs.hobby?.id;
    }
}

