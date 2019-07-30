//
//  HobbyDetailViewController.swift
//  Harrastuspassi
//
//  Created by Tiia Trogen on 25/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class HobbyDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var hobbyEvent: HobbyEventData?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        titleLabel.text = hobbyEvent?.name
        dayOfWeekLabel.text = hobbyEvent?.startDayOfWeek
        if let date = hobbyEvent?.startDate {
            dateLabel.text = dateFormatter.string(from: date)
        }
        if let event = hobbyEvent {
            if let imageUrl = event.image {
                let url = URL (string: imageUrl)
                imageView.loadurl(url: url!)
            } else {
                imageView.image = UIImage(named: "ic_panorama")
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchUrl(url: String) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url : URL? = URL(string: url)
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
        
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let eventData = try? JSONDecoder().decode(HobbyEventData.self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        self.titleLabel.text = "Jokin meni vikaan"
                    })
                    return
            }
            
            DispatchQueue.main.async(execute: {() in
                self.hobbyEvent = eventData
            })
        }
    }
    
    func reloadData() {
        
    }
}
