//
//  SelectionDelegate.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 15/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

protocol SelectionDelegate: class {
    var selectedItems: [Int] {get set};
    func addSelection(selectedItem: CategoryData);
    func removeSelection(removedItem: CategoryData);
    func saveFiltersAndDismiss();
}
