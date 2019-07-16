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

    var data: [HobbyEvent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        data = [
            HobbyEvent("Jalkapallo"),
            HobbyEvent("Jaakiekko"),
            HobbyEvent("Eukonkanto"),
            HobbyEvent("Taekwondo"),
            HobbyEvent("Kitaransoiton alkeet")
        ]
        //self.view.setNeedsLayout()
       //self.view.layoutIfNeeded()

        hobbyTableView.delegate = self
        hobbyTableView.dataSource = self
        
    }
    
    
    //MARK: Tableview setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = data {
            return d.count
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyTableViewCell", for: indexPath) as! HobbyTableViewCell
        if let d = data {
            cell.setHobbyEvents(hobbyEvent: d[indexPath.row])
        }
        
        return cell
    }
    
    /*@objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let vc =  storyboard!.instantiateViewController(withIdentifier: "detailsVc") as! DetailsViewController
        vc.data = data?[pageControl.currentPage]
        present(vc, animated: true, completion: nil)
    }
   */
}
