//
//  CategoryFilterMap.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 14/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    
    class func formatTimeFrom(float: CGFloat) -> String {
        let h = Int(float/60);
        let m = Int(float.truncatingRemainder(dividingBy: 60));
        return String(format: "%02d:%02d", h, m);
    }
    
    class func formatDateFromString(_ string:String) -> String {
        let getDateFormatter  = DateFormatter()
        getDateFormatter.dateFormat = "yyyy-MM-dd"
        let dateOutputDateFormatter = DateFormatter()
        dateOutputDateFormatter.dateFormat = "dd.MM.yyyy"
        if let date = getDateFormatter.date(from: string) {
            return dateOutputDateFormatter.string(from: date)
        }
        return "N/A"
        
    }
    
    class func getDefaultFilters() -> Filters {
        let defaults = UserDefaults.standard;
        var filters = Filters();
        
        if let filteredCategories = defaults.array(forKey: DefaultKeys.Filters.categories) as? [Int], filteredCategories.count > 0  {
            filters.categories = filteredCategories
        }
        
        if let filteredWeekdays = defaults.array(forKey: DefaultKeys.Filters.weekdays) as? [Int] {
            filters.weekdays = filteredWeekdays
        }
        
        if let startTime = defaults.float(forKey: DefaultKeys.Filters.startTime) as Float?, let endTime = defaults.float(forKey: DefaultKeys.Filters.endTime) as Float?, endTime > 0 {
            let minValue = CGFloat(startTime);
            let maxValue = CGFloat(endTime);
            
            filters.times.minTime = minValue;
            filters.times.maxTime = maxValue;
        } else {
            filters.times.minTime = 0.0;
            filters.times.maxTime = 1439.0;
        }
        
        return filters;
    }
}
