//
//  HobbyDetailViewController.swift
//  Harrastuspassi
//
//  Created by Tiia Trogen on 25/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps

class HobbyDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var hobbyEvent: HobbyEventData?
    var camera: GMSCameraPosition?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        titleLabel.text = hobbyEvent?.name
        if let d = hobbyEvent?.startDayOfWeek {
            dayOfWeekLabel.text = d
        }
        
        if let event = hobbyEvent {
            if let imageUrl = event.image {
                let url = URL (string: imageUrl)
                imageView.loadurl(url: url!)
            } else {
                imageView.image = UIImage(named: "ic_panorama")
            }
        }
        
        guard let id = hobbyEvent?.id else {
            return
        }
        fetchUrl(url: Config.API_URL + String(id))
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
                        HPAlert.presentAlertWithTitle("Virhe", message: "Jokin meni vikaan.", presenter: self, completion: {
                            (UIAlertAction) in
                            self.navigationController?.popViewController(animated: true);
                        })
                    })
                    return
            }
            
            DispatchQueue.main.async(execute: {() in
                self.hobbyEvent = eventData
                self.reloadData()
                self.setUpMapView()
            })
        }
    }
    
    func reloadData() {
        let getDateFormatter  = DateFormatter()
        getDateFormatter.dateFormat = "yyyy-MM-dd"
        let getTimeFormatter = DateFormatter()
        getTimeFormatter.dateFormat = "HH:mm:ss"
        guard let event = hobbyEvent, let d = hobbyEvent?.startDate, let t = hobbyEvent?.startTime else {
            return
        }
        
        let date = getDateFormatter.date(from: d)
        let time = getTimeFormatter.date(from: t)
        let dateOutputDateFormatter = DateFormatter()
        dateOutputDateFormatter.dateFormat = "dd.MM.yyyy"
        let timeOutputFormatter = DateFormatter()
        timeOutputFormatter.dateFormat = "HH:mm"
        
        organizerLabel.text = event.organizer
        if let t = time { timeLabel.text = timeOutputFormatter.string(from: t) }
        locationLabel.text = event.location?.name
        descriptionLabel.text = event.description
        if let d = date { dateLabel.text = dateOutputDateFormatter.string(from: d) }
        guard let location = event.location else {
            return
        }
        if let zipCode = location.zipCode, let address = location.address, let city = location.city {
            addressLabel.text = address + ", " + zipCode + ", " + city
        }
        
    }
    
    func setUpMapView() {
        guard let lat = hobbyEvent?.location?.lat, let lon = hobbyEvent?.location?.lon, let title = hobbyEvent?.name, let snippet = hobbyEvent?.location?.name else {
            return
        }
        camera = GMSCameraPosition.camera(withLatitude: Double(lat), longitude: Double(lon), zoom: 12.0)
        guard let cam = camera else {
            return
        }
        self.view.layoutIfNeeded()
        mapView.animate(to: cam)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lon))
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
    }
}
