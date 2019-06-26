//
//  HomeViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 12/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var hobbyTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var data: [HobbyEvent]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        data = [
            HobbyEvent("Jalkapallo"),
            HobbyEvent("Jaakiekko"),
            HobbyEvent("Eukonkanto"),
            HobbyEvent("Taekwondo")
        ]
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        let slides = createPromoSlides()
        if let s = slides {
            setupSlideScrollView(slides: s)
            pageControl.numberOfPages = s.count
            pageControl.currentPage = 0
            view.bringSubviewToFront(pageControl)
        }
        scrollView.delegate = self
        hobbyTableView.delegate = self
        hobbyTableView.dataSource = self
    }
    
    
    //MARK: Create promotion banner
    
    
    
    //MARK: Tableview setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = data {
            return d.count
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hobbyTableView.dequeueReusableCell(withIdentifier: "HobbyEventListCell", for: indexPath)
        if let d = data {
            cell.textLabel?.text = d[indexPath.row].name
        }
        return cell
    }
    
    func createPromoSlides() -> [Slide]? {
        
        var slides: [Slide] = []
        
        if let d = data {
            for element in d {
                let slide:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                slide.imageView.image = UIImage(named: "soccer-placeholder")
                slide.titleLabel.text = element.name
                slide.layer.cornerRadius = 15
                slide.layer.masksToBounds = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                slide.addGestureRecognizer(tap)
                slides.append(slide)
            }
            return slides
        }
        return nil
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let vc =  storyboard!.instantiateViewController(withIdentifier: "detailsVc") as! DetailsViewController
        vc.data = data?[pageControl.currentPage]
        present(vc, animated: true, completion: nil)
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        print(scrollView.frame.width * CGFloat(slides.count))
        print(scrollView.frame.width)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
   
}
