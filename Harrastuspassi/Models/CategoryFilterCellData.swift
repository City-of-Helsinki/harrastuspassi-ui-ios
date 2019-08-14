//
//  CategoryFilterCellData.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 14/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct CategoryFilterCellData {
    var opened = Bool()
    var hasChildren = Bool()
    var category: CategoryData?
    var sectionData = [CategoryFilterCellData]()
}
