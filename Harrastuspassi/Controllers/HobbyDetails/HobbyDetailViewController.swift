//
//  HobbyDetailViewController.swift
//  Harrastuspassi
//
//  Created by Tiia Trogen on 25/07/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps
import Hero

class HobbyDetailViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var panGR: UIPanGestureRecognizer!
    var hobbyEvent: HobbyEventData?
    var camera: GMSCameraPosition?
    var heroID: String?
    var imageHeroID: String?
    var titleHeroID: String?
    var locationHeroID: String?
    var dayOfWeekLabelHeroID: String?
    var dismissStarted = false;
    var eventData = [HobbyEventData]();
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var organizerLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var eventTableView: EventTableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var startingOffset: CGFloat = 0;
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.hero.isEnabled = true;
        view.hero.id = heroID;
        imageView.hero.id = imageHeroID;
        titleLabel.hero.id = titleHeroID;
        locationLabel.hero.id = locationHeroID;
        closeButton.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude);
        closeButton.hero.isEnabled = true;
        closeButton.hero.modifiers = [.duration(0.7), .translate(x:100), .useGlobalCoordinateSpace];
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)));
        panGR.delegate = self
        scrollView.addGestureRecognizer(panGR);
        scrollView.bounces = false;
        startingOffset = scrollView.contentOffset.y;
        closeButton.layer.cornerRadius = 15;
        closeButton.clipsToBounds = true;
        
        if let event = hobbyEvent {
            titleLabel.text = event.hobby?.name
            if let img = image {
                imageView.image = img
                
            } else if let imageUrl = event.hobby?.image {
                let url = URL (string: imageUrl)
                imageView.loadurl(url: url!, completition: nil);
            } else {
                imageView.image = UIImage(named: "ic_panorama")
            }
        }
        eventTableView.delegate = self;
        eventTableView.dataSource = self;
        reloadData();
        setUpMapView();
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func reloadData() {
        let getDateFormatter  = DateFormatter()
        getDateFormatter.dateFormat = "yyyy-MM-dd"
        let getTimeFormatter = DateFormatter()
        getTimeFormatter.dateFormat = "HH:mm:ss"
        guard let event = hobbyEvent else {
            return
        }
        organizerLabel.text = event.hobby?.organizer?.name
        locationLabel.text = event.hobby?.location?.name
        descriptionLabel.text = event.hobby?.description
        guard let location = event.hobby?.location else {
            return
        }
        if let zipCode = location.zipCode, let address = location.address, let city = location.city {
            addressLabel.text = address + ", " + zipCode + ", " + city
        }
        activityIndicator.isHidden = false;
        activityIndicator.startAnimating();
        fetchUrl(urlString: Config.API_URL + "hobbyevents")
    }
    
    func setUpMapView() {
        guard let lat = hobbyEvent?.hobby?.location?.lat, let lon = hobbyEvent?.hobby?.location?.lon, let title = hobbyEvent?.hobby?.name, let snippet = hobbyEvent?.hobby?.location?.name else {
            return
        }
        camera = GMSCameraPosition.camera(withLatitude: Double(lat), longitude: Double(lon), zoom: 12.0)
        guard let cam = camera else {
            return
        }
        self.view.layoutIfNeeded()
        mapView.camera = cam;
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lon))
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
    }
    
    @objc func handlePan(gestureRecognizer:UIPanGestureRecognizer) {
        let translation = panGR.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        switch panGR.state {
        case .began:
            // begin the transition as normal
            if scrollView.contentOffset.y == self.startingOffset {
                print("OFFSET 0")
                
            }
            
        case .changed:
            // calculate the progress based on how far the user moved
            let translation = panGR.translation(in: nil)
            let progress = translation.y / 2 / view.bounds.height
            if scrollView.isAtTop && panGR.direction == .down && !dismissStarted {
                dismissStarted = true;
                dismiss(animated: true, completion: nil)
            }
            if dismissStarted {
                Hero.shared.update(CGFloat(progress))
            }
        default:
            if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 && dismissStarted {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
                dismissStarted = false;
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData.count;
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventTableViewCell;
        let event = eventData[indexPath.row];
        if let index = event.startDayOfWeek {
            cell.weekdayLabel.text = Weekdays().list[index-1].name;
        }
        let getDateFormatter  = DateFormatter()
        getDateFormatter.dateFormat = "yyyy-MM-dd"
        let getTimeFormatter = DateFormatter()
        getTimeFormatter.dateFormat = "HH:mm:ss"
        guard let d = event.startDate, let t = event.startTime, let et = event.endTime else {
            return UITableViewCell();
        }
        let dateOutputDateFormatter = DateFormatter()
        dateOutputDateFormatter.dateFormat = "dd.MM.yyyy"
        let timeOutputFormatter = DateFormatter()
        timeOutputFormatter.dateFormat = "HH:mm"
        if let date = getDateFormatter.date(from: d), let time = getTimeFormatter.date(from: t), let endTime = getTimeFormatter.date(from: et) {
            cell.dateLabel.text = dateOutputDateFormatter.string(from: date);
            cell.timeLabel.text = timeOutputFormatter.string(from: time) + "-" + timeOutputFormatter.string(from: endTime)
        }
        return cell;
    }
    
    // MARK: - Data Fetching
    
    func fetchUrl(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        var url: URL?;
        url = applyQueryParamsToUrl(urlString);
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
    
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        print(response)
        if let fetchedData = data {
            var eventsData = [HobbyEventData]();
            do {
                eventsData = try JSONDecoder().decode([HobbyEventData].self, from: fetchedData)
            } catch {
                print(error)
            }
//            guard let eventsData = try?  else {
//                    print("FAILED")
//                    return
//            }
            print(eventsData)
            DispatchQueue.main.async(execute: {() in
                self.activityIndicator.stopAnimating();
                self.activityIndicator.isHidden = true;
                self.activityIndicator.removeFromSuperview();
                self.eventTableView.tableFooterView = nil
                if(eventsData.count == 0) {
                    print("0 events")
                    return;
                } else {
                    self.eventData = Array(eventsData.prefix(5));
                    print(self.eventData.count)
                    UIView.transition(with: self.eventTableView,
                                      duration: 0.35,
                                      options: .transitionCurlDown,
                                      animations: { self.eventTableView.reloadData() })
                }
            })
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "hobby", value: String(hobbyEvent!.hobby!.id!)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"));
        return urlComponents?.url
    }
}
