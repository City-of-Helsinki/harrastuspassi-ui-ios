//
//  HobbyListModalViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 31.10.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class HobbyListModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var events: [HobbyEventData] = [];
    var titleText: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titlelabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self;
        tableView.delegate = self;
        titlelabel.text = titleText;
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyTableViewCell", for: indexPath) as! HobbyTableViewCell;
        cell.setHobbyEvents(hobbyEvent: event);
        cell.hobbyImage?.hero.id = "image" + String(indexPath.row);
        cell.title.hero.id = "title" + String(indexPath.row);
        cell.location.hero.id = "location" + String(indexPath.row);
        cell.date.hero.id = "weekday" + String(indexPath.row);
        cell.contentView.hero.isEnabled = true;
        cell.contentView.hero.id = String(indexPath.row);
        cell.selectionStyle = .none
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if segue.identifier == Segues.details {
            guard let detailViewController = segue.destination as? HobbyDetailViewController,
                let index = tableView.indexPathForSelectedRow?.row, let path = tableView.indexPathForSelectedRow
                else {
                    return
            }
            
            detailViewController.hobbyEvent = events[index]
            detailViewController.heroID = String(index);
            detailViewController.imageHeroID = "image" + String(index);
            detailViewController.titleHeroID = "title" + String(index);
            detailViewController.locationHeroID = "location" + String(index);
            detailViewController.dayOfWeekLabelHeroID = "weekday" + String(index);
            //detailViewController.titleHeroID = "title" + String(index);
            detailViewController.image = (tableView.cellForRow(at: path) as! HobbyTableViewCell).hobbyImage.image;
            
            self.hero.modalAnimationType = .selectBy(presenting:.none, dismissing:.none);
            detailViewController.hero.modalAnimationType = .selectBy(presenting: .none, dismissing: .none);
            
        }
    }
}
