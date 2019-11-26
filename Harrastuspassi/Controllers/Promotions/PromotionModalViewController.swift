//
//  PromotionModalViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import MTSlideToOpen

class PromotionModalViewController: UIViewController, MTSlideToOpenDelegate {
    
    @IBOutlet weak var slideButton: MTSlideToOpenView!
    @IBOutlet weak var promotionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var offerStateLabel: UILabel!
    
    var promotion = PromotionData();
    
    let feedbackGenerator = UIImpactFeedbackGenerator();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = promotion.image {
            promotionImageView.kf.setImage(with: URL(string: image)!);
        } else {
            promotionImageView.image = UIImage(named: "logo_lil_yel");
        }
        offerStateLabel.isHidden = true;
        titleLabel.text = promotion.name;
        descriptionLabel.text = promotion.description;
        slideButton.sliderViewTopDistance = 0;
        slideButton.sliderCornerRadius = 30
        slideButton.sliderHolderView.frame = slideButton.frame;
        slideButton.defaultSliderBackgroundColor = UIColor(named: "mainColorAlpha")!
        slideButton.defaultSlidingColor = UIColor(named: "mainColor")!
        slideButton.delegate = self
        slideButton.defaultLabelText = "Slide use this offer"
        slideButton.thumnailImageView.image = UIImage(named: "ic_local_activity")
        slideButton.defaultThumbnailColor = UIColor(named: "mainColor")!
        
        if promotion.isUsed() {
            slideButton.isHidden = true;
            offerStateLabel.isHidden = false;
        }

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        print("Slide completed!");
        feedbackGenerator.impactOccurred();
        promotion.use();
        self.offerStateLabel.transform = CGAffineTransform(scaleX: 0, y: 0);
        UIView.animate(withDuration: 0.2, animations: {
            self.slideButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.offerStateLabel.isHidden = false;
        }, completion: { _ in
            self.slideButton.isHidden = true;
            UIView.animate(withDuration: 0.2) {
                self.offerStateLabel.transform = CGAffineTransform(scaleX: 1, y: 1);
            }
        })
    };
}
