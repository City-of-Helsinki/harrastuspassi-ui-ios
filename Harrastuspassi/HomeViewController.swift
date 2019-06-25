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
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var promoTitle: UILabel!
    @IBOutlet weak var promoImage: UIImageView!
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var label: UILabel!
    
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
        hobbyTableView.delegate = self
        hobbyTableView.dataSource = self
        
        if let d = data {
            pageControl.numberOfPages = d.count
            pageControl.currentPage = 0
            promoTitle?.text = d[0].name
            promoImage?.image = UIImage(named: "soccer-placeholder")
            view.bringSubviewToFront(pageControl)
            promoView.layer.cornerRadius = 10
            promoView.layer.masksToBounds = true
        }
        
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        promoView.addGestureRecognizer(leftSwipe)
        promoView.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
    {
        
        let currentPage = pageControl.currentPage
        if (sender.direction == .right)
        {
            if let d = data {
                print("Swipe Left")
                if currentPage == 0 {
                    pageControl.currentPage = d.count - 1
                    promoTitle.text = d[d.count - 1].name
                } else {
                    pageControl.currentPage = currentPage - 1
                    promoTitle.text = d[currentPage - 1].name
                }
            }
            
        }
        
        if (sender.direction == .left)
        {
            
            if let d = data {
                print("Swipe Left")
                if currentPage == d.count - 1 {
                    pageControl.currentPage = 0
                    promoTitle.text = d[0].name
                } else {
                    pageControl.currentPage = currentPage + 1
                    promoTitle.text = d[currentPage + 1].name
                }
            }
            print("Swipe Right")
            
            // show the view from the left side
        }
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
   
}
