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
        
        self.fetchUrl(url: "http://10.0.1.172:8000/hobbies/")
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
    
    func fetchUrl(url: String) {
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let url : URL? = URL(string: url)
        
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
        
        print(data)
        // Starts the task, spawns a new thread and calls the callback function
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        guard let eventData = try? JSONDecoder().decode(HobbyEventData.self, from: data!)
        else {
                print("Error occured")
                return
        }
    }

        //self.hobbyTableView.reloadData()
 
    /* if let url = URL(string: url) {
        do {
            let events = try String(contentsOf: url)
            print(events)
        } catch {
            // contents could not be loaded
        }
    } else {
    // the URL was bad!
    print("No url")
    
    }
   */
     
     
     /*   @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let vc =  storyboard!.instantiateViewController(withIdentifier: "detailsVc") as! DetailsViewController
        vc.data = data?[pageControl.currentPage]
        present(vc, animated: true, completion: nil)
    }
   */
}
