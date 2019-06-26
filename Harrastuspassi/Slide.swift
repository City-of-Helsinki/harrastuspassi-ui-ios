//
//  Slide.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 25/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class Slide: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func resetTransform() {
        transform = .identity
    }

}
