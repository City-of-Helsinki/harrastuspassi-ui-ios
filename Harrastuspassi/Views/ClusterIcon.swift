//
//  ClusterIcon.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 30/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class ClusterIcon: UIView {

    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var label: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    init(frame: CGRect, amountOfItems: Int) {
        super.init(frame: frame);
        commonInit();
        label.text = String(amountOfItems);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        commonInit();
    }
    
    func commonInit() {
        print("Custom view here I come")
        Bundle.main.loadNibNamed("ClusterIcon", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.layer.cornerRadius = self.frame.width / 2;
        contentView.layer.masksToBounds = true;
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth];
    }
}
