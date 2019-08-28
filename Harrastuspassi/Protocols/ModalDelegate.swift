//
//  ModalDelegate.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 19/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

protocol ModalDelegate {
    func didCloseModal(data: Filters?);
}
