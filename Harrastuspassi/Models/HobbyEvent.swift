//
//  HobbyEvent.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 13/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

class HobbyEvent {
    
    //MARK: Properties
    
    var name: String
    var imageUrl: URL?
    var startDate: Date
    var endDate: Date
    var placeholderImage: UIImage?
    
    init(_ name:String = "Placeholder", _ imageUrl:URL? = nil) {
        self.name = name
        if let url = imageUrl {
            self.imageUrl = url;
        } else {
            placeholderImage = UIImage(named: "ic_panorama")
        }
        startDate = Date()
        endDate = Date()
    }
    
}
