//
//  POIItem.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 26/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import CoreLocation

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var id: Int!
    
    init(position: CLLocationCoordinate2D, name: String, id: Int) {
        self.position = position;
        self.name = name;
        self.id = id
    }
}
