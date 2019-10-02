//
//  MapInfoView.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 24/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class MapInfoView: UIView {
    
    // MARK: - Initialization
    
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var onPress: (() -> Void)?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        commonInit();
    }
    
    init(frame: CGRect, onPress: (()->Void)?) {
        super.init(frame: frame);
        self.onPress = onPress;
        commonInit();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        commonInit();
    }
    
    func commonInit() {
        print("Custom view here I come")
        Bundle.main.loadNibNamed("MapInfoView", owner: self, options: nil);
        addSubview(contentView);
        contentView.frame = self.bounds;
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth];
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.pressAction))
        self.contentView.addGestureRecognizer(gesture)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

    @objc func pressAction() {
        if let f = self.onPress {
            f();
        }
    }
    
    func setImage(urlString: String?, completition: @escaping () -> Void) {
        if let string = urlString, let url = URL(string: string) {
            imageView.loadurl(url: url, completition: completition);
        } else {
            imageView.image = UIImage(named: "ic_panorama");
        }
    }
}
