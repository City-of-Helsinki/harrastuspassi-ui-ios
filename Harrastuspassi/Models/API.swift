//
//  API.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 29.1.2020.
//  Copyright © 2020 Haltu. All rights reserved.
//

import Foundation

struct HobbyEventResponse: Codable {
    
    let count : Int?
    let next : String?
    let previous : String?
    let results : [HobbyEventData]?
    
    enum CodingKeys: String, CodingKey {
        
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
        
    }

}

struct PromotionResponse: Codable {
    
    let count : Int?
    let next : String?
    let previous : String?
    let results : [PromotionData] = []
    
    enum CodingKeys: String, CodingKey {
        
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
        
    }

}

struct CategoryResponse: Codable {
    
    let count : Int?
    let next : String?
    let previous : String?
    let results : [CategoryData] = []
    
    enum CodingKeys: String, CodingKey {
        
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
        
    }

}
