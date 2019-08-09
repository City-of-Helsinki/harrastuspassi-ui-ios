//
//  CategoryData.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 09/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct CategoryData : Codable {
    let id : Int?
    let name : String?
    let treeId : Int?
    let level : Int?
    let parent : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case treeId = "tree_id"
        case level = "level"
        case parent  = "parent"
    }
}
