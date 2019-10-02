//
//  EventTableView.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 02/10/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class EventTableView: UITableView {

    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override func reloadData() {
      super.reloadData()
      self.invalidateIntrinsicContentSize()
      self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
      let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: contentSize.height)
    }

}
