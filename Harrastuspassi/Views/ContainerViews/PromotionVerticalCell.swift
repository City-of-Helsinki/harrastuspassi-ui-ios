//
//  PromotionVerticalCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 20.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class PromotionVerticalCell: UIView {

    let nibName = "PromotionVerticalCell"
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

}
