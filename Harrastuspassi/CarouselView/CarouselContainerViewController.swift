//
//  CarouselContainerCell.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 14/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CarouselContainerViewConroller: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var data: [HobbyEvent]?
    
    var subViews: [CarouselElementView] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialization code
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        createSubViews()
        for view in subViews {
            scrollView.addSubview(view)
        }
        if let d = data {
            pageControl.numberOfPages = d.count
            pageControl.currentPage = 0
            scrollView.bringSubviewToFront(pageControl)
        }
    }
    
    override func awakeFromNib() {
        
    }
    
    func createSubViews() {
        if let d = data {
            for element in d {
                let view = CarouselElementView();
                view.titleLabel.text = element.name
                view.imageView.image = UIImage(named: "ic_panorama")
                self.subViews.append(view)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
            
            subViews[0].imageView.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            subViews[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
            
        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
            subViews[1].imageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
            subViews[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
            subViews[2].imageView.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
            subViews[3].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
            
        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            subViews[3].imageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            subViews[4].imageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
    }
    
}
