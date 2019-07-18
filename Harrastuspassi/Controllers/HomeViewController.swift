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
    @IBOutlet weak var errorText: UILabel!
    
    var hobbyData: [HobbyEventData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hobbyTableView.delegate = self
        hobbyTableView.dataSource = self
        self.errorText.isHidden = true
        
        self.fetchUrl(url: "http://10.0.1.172:8000/mobile-api/hobbies/")
    }
    
    // Tableview setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = hobbyData {
            return d.count
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyTableViewCell", for: indexPath) as! HobbyTableViewCell
        if let d = hobbyData {
            cell.setHobbyEvents(hobbyEvent: d[indexPath.row])
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func fetchUrl(url: String) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url : URL? = URL(string: url)
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
        
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        guard let eventData = try? JSONDecoder().decode([HobbyEventData].self, from: data!)
        else {
            self.errorText.isHidden = false
            self.errorText.text = "Jokin meni vikaan"
            return
        }
        
        DispatchQueue.main.async(execute: {() in
            if(eventData.count == 0) {
                self.errorText.text = "Ei harrastustapahtumia"
                self.errorText.isHidden = false
            } else {
                self.hobbyData = eventData
                self.hobbyTableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = UIRectEdge.bottom
        extendedLayoutIncludesOpaqueBars = true
    }
}
