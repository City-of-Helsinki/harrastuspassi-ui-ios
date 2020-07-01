//
//  Filters.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 19/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

struct Filters {
    var categories:[Int] = [];
    var weekdays:[Int] = [];
    var times = Times();
    var price_type: String?;
}

struct Weekday {
    let id: Int;
    let name: String;
    let selected = false;
}

struct Weekdays {
    let list = [
        Weekday(id: 1, name: NSLocalizedString("Monday", comment: "")),
        Weekday(id: 2, name: NSLocalizedString("Tuesday", comment: "")),
        Weekday(id: 3, name: NSLocalizedString("Wednesday", comment: "")),
        Weekday(id: 4, name: NSLocalizedString("Thursday", comment: "")),
        Weekday(id: 5, name: NSLocalizedString("Friday", comment: "")),
        Weekday(id: 6, name: NSLocalizedString("Saturday", comment: "")),
        Weekday(id: 7, name: NSLocalizedString("Sunday", comment: ""))
    ];
}

struct Times {
    var minTime: CGFloat = 0.0;
    var maxTime: CGFloat = 1439;
}
