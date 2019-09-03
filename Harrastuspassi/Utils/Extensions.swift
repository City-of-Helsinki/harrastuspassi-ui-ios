//
//  Extensions.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 16/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
