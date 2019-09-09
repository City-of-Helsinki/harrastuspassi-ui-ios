//
//  LocationListDelegate.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 09/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

protocol LocationListDelegate {
    func didSaveLocation(_ coordinates: [CoordinateData]);
}
