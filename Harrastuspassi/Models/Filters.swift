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
}

struct Weekday {
    let id: Int;
    let name: String;
    let selected = false;
}

struct Weekdays {
    let list = [Weekday(id: 1, name: "Maanantai"), Weekday(id: 2, name: "Tiistai"), Weekday(id: 3, name: "Keskiviikko"),Weekday(id: 4, name: "Torstai"),Weekday(id: 5, name: "Perjantai"),Weekday(id: 6, name: "Lauantai"),Weekday(id: 7, name: "Sunnuntai")];
}

struct Times {
    var minTime: CGFloat = 480.0;
    var maxTime: CGFloat = 1260.0;
}
