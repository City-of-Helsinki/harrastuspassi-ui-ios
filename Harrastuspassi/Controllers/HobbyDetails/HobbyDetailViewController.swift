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
import Firebase

class HobbyDetailViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var panGR: UIPanGestureRecognizer!
    var hobbyEvent: HobbyEventData?
    var hobbyEventID: Int?
    var navigatedFromDynamicLink = false;
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
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var eventTableView: EventTableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var shareActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var linkActivityIndicator: UIActivityIndicatorView!
    
    var startingOffset: CGFloat = 0;
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        eventTableView.delegate = self;
        eventTableView.dataSource = self;
        linkActivityIndicator.isHidden = true;
        let defaults = UserDefaults.standard;
        let lat = defaults.float(forKey: DefaultKeys.Location.lat);
        let lon = defaults.float(forKey: DefaultKeys.Location.lon);
        let finland = GMSCameraPosition.camera(withLatitude: Double(lat),
                                               longitude: Double(lon),
                                               zoom: 10);
        mapView.camera = finland;

        if !navigatedFromDynamicLink {
            setupUI();
        } else {
            setupUIFromLink();
        }
        shareActivityIndicator.isHidden = true;
        if isFavorite() {
            favouriteButton.setImage(UIImage(named: "ic_favorite")?.withRenderingMode(.alwaysTemplate), for: .normal);
            favouriteButton.tintColor = UIColor(named: "mainColor");
        }
        mapView.preferredFrameRate = .conservative;
        mapView.isUserInteractionEnabled = false;
        descriptionTextView.dataDetectorTypes = .link;
        
        if #available(iOS 13.0, *) {
            self.hero.isEnabled = true;
            closeButton.hero.isEnabled = true;
            closeButton.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude);
            closeButton.hero.modifiers = [.duration(0.7), .translate(x:100), .useGlobalCoordinateSpace];
        } else {
            self.hero.isEnabled = false;
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.dismiss(animated: false, completion: nil);
    }
    
    func setupUI() {
        view.hero.isEnabled = true;
        view.hero.id = heroID;
        imageView.hero.id = imageHeroID;
        titleLabel.hero.id = titleHeroID;
        locationLabel.hero.id = locationHeroID;
        
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
                imageView.kf.setImage(with: url);
            } else {
                imageView.image = UIImage(named: "ic_panorama")
            }
        }
        reloadData();
        setUpMapView();
    }
    
    func setupUIFromLink() {
        linkActivityIndicator.isHidden = false;
        linkActivityIndicator.startAnimating();
        panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)));
        panGR.delegate = self
        scrollView.addGestureRecognizer(panGR);
        scrollView.bounces = false;
        startingOffset = scrollView.contentOffset.y;
        closeButton.layer.cornerRadius = 15;
        closeButton.clipsToBounds = true;
        let url = Config.API_URL + "hobbyevents/" + String(hobbyEventID!) + "?include=hobby_detail"+"&include=location_detail"+"&include=organizer_detail";
        print(url);
        fetchHobbyFromUrl(url);
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
        titleLabel.text = event.hobby?.name
        organizerLabel.text = event.hobby?.organizer?.name
        locationLabel.text = event.hobby?.location?.name
        if let description = event.hobby?.description {
            descriptionTextView.text = description;
        }
        
        guard let location = event.hobby?.location else {
            return
        }
        if let zipCode = location.zipCode, let address = location.address, let city = location.city {
            addressLabel.text = address + ", " + zipCode + ", " + city
        }
        if let imageUrl = event.hobby?.image {
            let url = URL (string: imageUrl)
            imageView.kf.setImage(with: url);
        } else {
            imageView.image = UIImage(named: "logo_lil_yel")
        }
        activityIndicator.isHidden = false;
        activityIndicator.startAnimating();
        print(Config.API_URL + "hobbyevents")
        fetchUrl(urlString: Config.API_URL + "hobbyevents")
    }
    
    
    func setUpMapView() {
        guard let lat = hobbyEvent?.hobby?.location?.coordinates?.coordinates?[1], let lon = hobbyEvent?.hobby?.location?.coordinates?.coordinates?[0], let title = hobbyEvent?.hobby?.name, let snippet = hobbyEvent?.hobby?.location?.name else {
            return
        }
        camera = GMSCameraPosition.camera(withLatitude: Double(lat), longitude: Double(lon), zoom: 16.0)
        print("camera", camera)
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
            if scrollView.isAtTop && panGR.direction == .down && !dismissStarted {
                dismissStarted = true;
                dismiss(animated: true, completion: nil)
            }
        case .changed:
            // calculate the progress based on how far the user moved
            let translation = panGR.translation(in: nil)
            let progress = translation.y / 2 / view.bounds.height
            
            if dismissStarted {
                Hero.shared.update(CGFloat(progress))
            }
        default:
            if progress + panGR.velocity(in: nil).y / view.bounds.height > 0.3 && dismissStarted {
                Hero.shared.finish()
                
            } else {
                print("ELSE", progress + panGR.velocity(in: nil).y / view.bounds.height)
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
            if timeOutputFormatter.string(from: time) == "00:00" && timeOutputFormatter.string(from: endTime) == "00:00" {
                cell.timeLabel.text = "-"
            } else {
                cell.dateLabel.text = dateOutputDateFormatter.string(from: date);
                cell.timeLabel.text = timeOutputFormatter.string(from: time) + "-" + timeOutputFormatter.string(from: endTime)

            }
            
        }
        return cell;
    }
    
    /*
     
    // MARK: - Data Fetching
     
    */
    
    func fetchUrl(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        var url: URL?;
        url = applyQueryParamsToUrl(urlString);
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
    
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let response = try? JSONDecoder().decode(HobbyEventResponse.self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        print("error")
                    })
                    return
            }
            guard let eventsData = response.results else {return};
//            guard let eventsData = try?  else {
//                    print("FAILED")
//                    return
//            }
            DispatchQueue.main.async(execute: {() in
                
                self.activityIndicator.stopAnimating();
                self.activityIndicator.isHidden = true;
                
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
                self.setUpMapView()
            })
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "hobby", value: String(hobbyEvent!.hobby!.id!)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "location_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "organizer_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "exclude_past_events", value: "true"))
        return urlComponents?.url
    }
    
    func fetchHobbyFromUrl(_ urlString: String) {
        let config = URLSessionConfiguration.default;
            let session = URLSession(configuration: config);
            let url = URL(string: urlString);
            let task = session.dataTask(with: url!, completionHandler: self.doneFetchingHobby);
        
            task.resume();
    }
    
    func doneFetchingHobby(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            var eventData: HobbyEventData?;
            do {
                eventData = try JSONDecoder().decode(HobbyEventData.self, from: fetchedData)
            } catch {
                print(error)
            }
            DispatchQueue.main.async(execute: {() in
                if let event = eventData {
                    print(event)
                    self.hobbyEvent = event;
                    self.linkActivityIndicator.isHidden = true;
                self.linkActivityIndicator.stopAnimating();
                    self.reloadData();
                    self.setUpMapView();
                }
            })
        }
    }
    
    /*
     
    // Mark: - Sharing
     
    */
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        shareButton.isHidden = true;
        shareActivityIndicator.isHidden = false;
        shareActivityIndicator.startAnimating();
        guard let link = constructLink() else { return };
        DynamicLinkComponents.shortenURL(link, options: nil) { url, warnings, error in
            self.shareButton.isHidden = false;
            self.shareActivityIndicator.isHidden = true;
            self.shareActivityIndicator.stopAnimating();
            guard let url = url else { return }
            print("The short URL is: \(url)")
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil);
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.markupAsPDF ];
            activityViewController.popoverPresentationController?.sourceView = self.shareButton;
            activityViewController.popoverPresentationController?.sourceRect = self.shareButton.bounds;
            self.present(activityViewController, animated: true, completion: {
                Analytics.logEvent("share", parameters: [
                    "hobbyId": self.hobbyEvent?.hobby?.id,
                    "hobbyName": self.hobbyEvent?.hobby?.name,
                    "provider": self.hobbyEvent?.hobby?.organizer?.name
                ]);
            });
        }
    }
    
    func constructLink() -> URL? {
        guard let link = URL(string: "https://hpassi.page.link/share/?hobbyEvent=" + String(hobbyEvent!.id!)) else { return nil }
        print(link)
        let dynamicLinksDomainURIPrefix = "https://hpassi.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        
        guard let builder = linkBuilder else {
            return nil;
        }

        builder.iOSParameters = DynamicLinkIOSParameters(bundleID: "fi.haltu.harrastuspassi")
        builder.iOSParameters?.appStoreID = "1473780933"
        builder.iOSParameters?.minimumAppVersion = "0.5.0"

        builder.androidParameters = DynamicLinkAndroidParameters(packageName: "fi.haltu.harrastuspassi")
        builder.androidParameters?.minimumVersion = 123

        builder.analyticsParameters = DynamicLinkGoogleAnalyticsParameters(source: "iOSMobile",
                                                                               medium: "social",
                                                                               campaign: "share")

        builder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        builder.socialMetaTagParameters?.title = hobbyEvent?.hobby?.name
        builder.socialMetaTagParameters?.descriptionText = hobbyEvent?.hobby?.organizer?.name
        if let image = hobbyEvent?.hobby?.image {
            builder.socialMetaTagParameters?.imageURL = URL(string: image);
        }
        builder.navigationInfoParameters = DynamicLinkNavigationInfoParameters();
        builder.navigationInfoParameters?.isForcedRedirectEnabled = true;
        guard let longDynamicLink = builder.url else { return nil }
        print("The long URL is: \(longDynamicLink)")
        
        return longDynamicLink;
    }
    
    
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        
        let defaults = UserDefaults.standard;
        var favourites: [Int] = [];
        if let storedFavourites = defaults.array(forKey: DefaultKeys.Favourites.list) as? [Int] {
            favourites = storedFavourites;
        }
        
        if !isFavorite() {
            favouriteButton.setImage(UIImage(named: "ic_favorite")?.withRenderingMode(.alwaysTemplate), for: .normal);
            favouriteButton.tintColor = UIColor(named: "mainColor");
            if let id = hobbyEvent?.hobby?.id {
                favourites.append(id);
            }
            Analytics.logEvent("addFavorite", parameters: [
                "hobbyId": "\(hobbyEvent?.hobby?.id ?? 0)",
                "hobbyName": hobbyEvent?.hobby?.name,
                "organizerName": hobbyEvent?.hobby?.organizer?.name,
            ])


        } else {
            favouriteButton.setImage(UIImage(named: "ic_favorite_border")?.withRenderingMode(.alwaysTemplate), for: .normal);
            favouriteButton.tintColor = UIColor(named: "mainColor");
            favourites = favourites.filter { $0 != hobbyEvent?.hobby?.id }
            Analytics.logEvent("removeFavorite", parameters: [
                "hobbyId": "\(hobbyEvent?.hobby?.id ?? 0)",
                "hobbyName": hobbyEvent?.hobby?.name,
                "organizerName": hobbyEvent?.hobby?.organizer?.name,
            ])
        }
        defaults.set(favourites, forKey: DefaultKeys.Favourites.list);
        
        print(favourites);
    }
    
    func isFavorite() -> Bool {
        let defaults = UserDefaults.standard;
        var favourites: [Int] = [];
        if let storedFavourites = defaults.array(forKey: DefaultKeys.Favourites.list) as? [Int] {
            favourites = storedFavourites;
        }
        
        let isFavourite = favourites.contains {
            $0 == hobbyEvent?.hobby?.id!
        }
        
        return isFavourite;
    }
    
}
