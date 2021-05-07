//
//  HomeViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 12/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import Hero
import CoreLocation
import Firebase
import Alamofire

class HomeViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource, ModalDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    // MARK: - Initialization
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var hobbyTableView: UITableView!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var rightButton: UIButton!
    
    
    var hobbyData = [HobbyEventData]();
    var filters = Filters();
    let refreshControl = UIRefreshControl();
    var searchValue: String? = nil;
    var nextPage: String?
    var pageSize = 50;
    var isFetching = false;
    
    let locationManager = CLLocationManager();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.hero.isEnabled = true;
        rightButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        rightButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        rightButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .none, dismissing: .none);
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged);
        refreshControl.tintColor = .white;
        
        navigationController?.delegate = self;
        searchBar.delegate = self;
        hobbyTableView.delegate = self
        hobbyTableView.dataSource = self
        hobbyTableView.refreshControl = refreshControl;
        self.errorText.isHidden = true
        filters = Utils.getDefaultFilters();
        containerView.hero.modifiers = [.forceNonFade];
        navigationController?.view.backgroundColor = UIColor(named: "mainColor")
        activityIndicator.isHidden = true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        filters = Utils.getDefaultFilters();
        
        if #available(iOS 13.0, *) {
            self.hero.isEnabled = true;
        } else {
            self.hero.isEnabled = false;
        }
        if let search = searchValue {
            searchBar.text = search;
            
        } else {
        }
        self.fetchUrl(urlString: Config.API_URL + "hobbyevents")
    }
    
    // Tableview setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hobbyData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyTableViewCell", for: indexPath) as! HobbyTableViewCell
        cell.setHobbyEvents(hobbyEvent: hobbyData[indexPath.row]);
        cell.hobbyImage?.hero.id = "image" + String(indexPath.row);
        cell.title.hero.id = "title" + String(indexPath.row);
        cell.location.hero.id = "location" + String(indexPath.row);
        cell.date.hero.id = "weekday" + String(indexPath.row);
        if #available(iOS 13.0, *) {
            cell.contentView.hero.isEnabled = true;
            cell.contentView.hero.id = String(indexPath.row);
            cell.selectionStyle = .none
        } else {
            self.hero.isEnabled = false;
        }
        return cell
    }
    
    func fetchUrl(urlString: String) {
        if !isFetching {
            var url: URL?;
            url = applyQueryParamsToUrl(urlString);
            if let initUrl = url {
                AF.request(initUrl, method: .get).response { response in self.doneFetching(data: response.data, response: response.response, error: response.error)}
            }
        }
    }
    
    func fetchNext() {
        if let nextPage = self.nextPage, !isFetching {
            activityIndicator.isHidden = false;
            activityIndicator.startAnimating();
            isFetching = true;
            AF.request(nextPage, method: .get).response { response in self.doneFetchingNext(data: response.data, response: response.response, error: response.error)}
        }
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let response = try? JSONDecoder().decode(HobbyEventResponse.self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        self.errorText.isHidden = false
                        self.errorText.text = NSLocalizedString("Something went wrong", comment:"");
                    })
                    return
            }
            guard let eventData = response.results else {return};
            if let nextPage = response.next {
                print(nextPage)
                self.nextPage = nextPage;
            }
            DispatchQueue.main.async(execute: {() in
                self.activityIndicator.isHidden = true;
                self.isFetching = false;
                self.refreshControl.endRefreshing();
                if(eventData.count == 0) {
                    self.hobbyData = Array(Set(eventData));
                    self.hobbyTableView.reloadData()
                    self.errorText.text = NSLocalizedString("No hobby events.", comment: "")
                    self.errorText.isHidden = false
                } else {
                    self.errorText.isHidden = true
                    self.hobbyData = eventData;
                    self.hobbyTableView.reloadData();
                }
                
            })
        }
    }
    
    func doneFetchingNext(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let response = try? JSONDecoder().decode(HobbyEventResponse.self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        self.errorText.isHidden = false
                        self.errorText.text = NSLocalizedString("Something went wrong", comment:"");
                    })
                    return
            }
            guard let eventData = response.results else {return};
            if let nextPage = response.next {
                self.nextPage = nextPage;
            } else {
                self.nextPage = nil;
            }
            DispatchQueue.main.async(execute: {() in
                self.activityIndicator.isHidden = true;
                self.isFetching = false;
                self.refreshControl.endRefreshing();
                if(eventData.count == 0) {
                    self.hobbyData = Array(Set(eventData));
                    self.hobbyTableView.reloadData()
                    self.errorText.text = NSLocalizedString("No hobby events.", comment: "")
                    self.errorText.isHidden = false
                } else {
                    self.errorText.isHidden = true
                    self.hobbyData.append(contentsOf: eventData);
                    self.hobbyTableView.reloadData();
                }
                
            })
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isFetching){
            self.fetchNext();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.details {
            guard let detailViewController = segue.destination as? HobbyDetailViewController,
                let index = hobbyTableView.indexPathForSelectedRow?.row, let path = hobbyTableView.indexPathForSelectedRow
                else {
                    return
            }
            
            if let hobby = hobbyData[index].hobby {
                
                var params = [
                    "hobbyId": hobby.id ?? 0,
                    "hobbyName": hobby.name!,
                    "organizerName": hobby.organizer?.name ?? "",
                    "free": true,
                    "postalCode": hobby.location?.zipCode ?? "",
                    "municipality": hobby.location?.city ?? ""
                    ] as [String : Any];
                for (index, category) in filters.categories.enumerated() {
                    params["category"+String(index)] = category;
                }
                
                Analytics.logEvent("viewHobby", parameters: params)
            };
            
            detailViewController.hobbyEvent = hobbyData[index]
            detailViewController.heroID = String(index);
            detailViewController.imageHeroID = "image" + String(index);
            detailViewController.titleHeroID = "title" + String(index);
            detailViewController.locationHeroID = "location" + String(index);
            detailViewController.dayOfWeekLabelHeroID = "weekday" + String(index);
            //detailViewController.titleHeroID = "title" + String(index);
            detailViewController.image = (hobbyTableView.cellForRow(at: path) as! HobbyTableViewCell).hobbyImage.image;
            
            self.hero.modalAnimationType = .selectBy(presenting:.none, dismissing:.none);
            detailViewController.hero.modalAnimationType = .selectBy(presenting: .none, dismissing: .none);
            
        } else if segue.identifier == Segues.filters {
            guard let filterModal = segue.destination as? FilterViewController else {
                return
            }
            filterModal.modalDelegate = self
        } else if segue.destination is MapViewController {
            let vc = segue.destination as? MapViewController
            vc?.searchTerm = searchValue
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func didCloseModal(data: Filters?) {
        
        if let d = data {
            filters = d;
            let defaults = UserDefaults.standard;
            defaults.set(d.categories, forKey: DefaultKeys.Filters.categories);
            defaults.set(d.weekdays, forKey: DefaultKeys.Filters.weekdays);
            defaults.set(d.times.minTime, forKey: DefaultKeys.Filters.startTime);
            defaults.set(d.times.maxTime, forKey: DefaultKeys.Filters.endTime);
            defaults.set(d.price_type, forKey: DefaultKeys.Filters.priceType);
        }
        fetchUrl(urlString: Config.API_URL + "hobbyevents")
    }
    
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "location_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "organizer_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "exclude_past_events", value: "true"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "page_size", value: String(pageSize)));
        //urlComponents?.queryItems?.append(URLQueryItem(name: "max_distance", value: String("50")));
        
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        
        if filters.categories.count > 0 {
            for id in filters.categories {
                urlComponents?.queryItems?.append(URLQueryItem(name: "category", value: String(id)))
            }
        }
        if filters.weekdays.count > 0 {
            for id in filters.weekdays {
                urlComponents?.queryItems?.append(URLQueryItem(name: "start_weekday", value: String(id)))
            }
        }
        if let priceType = filters.price_type {
            if priceType == "free" {
                urlComponents?.queryItems?.append(URLQueryItem(name: "price_type", value: priceType))
            }
            
        }
        urlComponents?.queryItems?.append(URLQueryItem(name: "start_time_from", value: Utils.formatTimeFrom(float: filters.times.minTime)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "start_time_to", value: Utils.formatTimeFrom(float: filters.times.maxTime)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "ordering", value: "nearest"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_latitude", value: String(latitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_longitude", value: String(longitude)));
        if let search = searchValue {
            urlComponents?.queryItems?.append(URLQueryItem(name: "search", value: search));
        }
        return urlComponents?.url
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.fetchUrl(urlString: Config.API_URL + "hobbyevents")
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        nextPage = nil;
        self.fetchUrl(urlString: Config.API_URL + "hobbyevents");
        searchBar.resignFirstResponder();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchValue = nil;
        self.fetchUrl(urlString: Config.API_URL + "hobbyevents");
        searchBar.resignFirstResponder();
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchValue = searchText;
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sb = UIStoryboard.init(name: "Main", bundle:nil)
//        let destinationvc = sb.instantiateViewController(withIdentifier: "DetailsVC") as! HobbyDetailViewController
//        if let data = hobbyData {
//            destinationvc.heroID = String(indexPath.row);
//            destinationvc.imageHeroID = "image" + String(indexPath.row);
//            destinationvc.titleHeroID = "title" + String(indexPath.row);
//            destinationvc.hobbyEvent = data[indexPath.row];
//            destinationvc.image = (tableView.cellForRow(at: indexPath) as! HobbyTableViewCell).hobbyImage.image;
//        }
//        self.hero.modalAnimationType = .selectBy(presenting:.zoom, dismissing:.zoomOut);
//        destinationvc.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
//        self.navigationController?.pushViewController(destinationvc, animated: true);
//
//    }
}
