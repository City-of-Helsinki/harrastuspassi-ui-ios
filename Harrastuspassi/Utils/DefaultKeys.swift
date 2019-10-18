//
//  Constants.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 15/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct DefaultKeys {
    
    static let categories = "categories"
    
    struct Filters {
        static let categories = "categoryFilters"
        static let categoriesTmp = "categoryFiltersTmp"
        static let weekdays = "weekdays"
        static let startTime = "startTime"
        static let endTime = "endTime"
    }
    
    struct Location {
        static let lon = "lon";
        static let lat = "lan";
        static let isAllowed = "isAllowed";
        static let savedLocations = "savedLocations";
        static let selectedLocation = "currentLocation";
    }
 
    struct Favourites {
        static let list = "FavouriteList";
    }
}

struct Segues {
    static let filters = "filters"
    static let details = "details"
}
