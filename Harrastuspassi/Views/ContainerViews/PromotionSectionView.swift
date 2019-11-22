//
//  PromotionSectionView.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 20.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

@IBDesignable
class PromotionSectionView: UIView {

    let nibName = "PromotionSectionView"
    
    var hobbies: [HobbyData] = []
    
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
        var subViews:[PromotionVerticalCell] = [];
        let cell: PromotionVerticalCell = PromotionVerticalCell(frame: CGRect(x: 0, y: 0, width: 200, height: 400));
        cell.heightAnchor.constraint(equalToConstant: 400).isActive = true;
        cell.widthAnchor.constraint(equalToConstant: 200).isActive = true;
        subViews.append(cell)
        let cell2: PromotionVerticalCell = PromotionVerticalCell(frame: CGRect(x: 0, y: 0, width: 200, height: 400));
        cell.heightAnchor.constraint(equalToConstant: 400).isActive = true;
        cell.widthAnchor.constraint(equalToConstant: 200).isActive = true;
        subViews.append(cell2)
        for view in subViews {
            contentView.addSubview(view);
        }
    }
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
