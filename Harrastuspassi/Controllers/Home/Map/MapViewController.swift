//
//  MapViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 19/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, ModalDelegate, GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private var clusterManager: GMUClusterManager!
    
    var hobbyData = [HobbyEventData]();
    var filters = Filters();
    var imageCache = Dictionary<Int, UIImage>();
    var markerIcon = UIImage(named:"ic_room")?.withRenderingMode(.alwaysTemplate);
    
    // MARK: - Initialization
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        filters = Utils.getDefaultFilters();
        self.hero.isEnabled = true;
        markerIcon = imageWithImage(image: markerIcon!, scaledToSize: CGSize(width: 40.0, height: 40.0)).withRenderingMode(.alwaysTemplate);
        setupClusterManager();
        
        let finland = GMSCameraPosition.camera(withLatitude: 61.9241,
                                               longitude: 25.7482,
                                               zoom: 6);
        mapView.camera = finland;
        updateData();
    }
    
    // MARK: - Data Fetching
    
    func updateData() {
        fetchUrl(urlString: Config.API_URL + "hobbyevents");
    }
    
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
            guard let eventData = try? JSONDecoder().decode([HobbyEventData].self, from: fetchedData)
                else {
                    return
            }
            print(eventData)
            DispatchQueue.main.async(execute: {() in
                if(eventData.count == 0) {
                    return;
                } else {
                    self.hobbyData = eventData.uniques;
                    self.createMarkers(data: self.hobbyData, mapView: self.mapView);
                }
            })
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        print(latitude, longitude);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
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
        //ordering=nearest&near_latitude=12.34567&near_longitude=12.34567
        urlComponents?.queryItems?.append(URLQueryItem(name: "start_time_from", value: Utils.formatTimeFrom(float: filters.times.minTime)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "start_time_to", value: Utils.formatTimeFrom(float: filters.times.maxTime)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "ordering", value: "nearest"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_latitude", value: String(latitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_longitude", value: String(longitude)));

        return urlComponents?.url
    }
    
    

    // MARK: - Navigation
    
    func didCloseModal(data: Filters?) {
        
        if let filters = data {
            self.filters = filters;
            let defaults = UserDefaults.standard;
            defaults.set(filters.categories, forKey: DefaultKeys.Filters.categories);
            defaults.set(filters.weekdays, forKey: DefaultKeys.Filters.weekdays);
            defaults.set(filters.times.minTime, forKey: DefaultKeys.Filters.startTime);
            defaults.set(filters.times.maxTime, forKey: DefaultKeys.Filters.endTime);
            updateData();
        }
    }
    
    func navigateToDetailViewWithindex(_ index: Int) {
        self.hero.isEnabled = true;
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsVC") as! HobbyDetailViewController
        newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
        newViewController.hobbyEvent = hobbyData[index];
        newViewController.heroID = String(index);
        newViewController.imageHeroID = "image" + String(index);
        if let image = imageCache[index] {
            newViewController.image = image;
        }
        
        present(newViewController, animated: true);
    }
    
    @IBAction func listViewButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: - Map Setup
    func createMarkers(data: [HobbyEventData], mapView: GMSMapView) {
        
        mapView.clear();
        
        let defaults = UserDefaults.standard;
        let userLongitude = defaults.float(forKey: DefaultKeys.Location.lon);
        let userLatitude = defaults.float(forKey: DefaultKeys.Location.lat);

        clusterManager.clearItems();
        
        for (index, event) in data.enumerated() {
            if let hobby = event.hobby, let location = hobby.location, let lat = location.lat, let lon = location.lon {
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(lat)), longitude: CLLocationDegrees(lon)));
                let markerView = UIImageView(image: markerIcon);
                marker.iconView = markerView;
                marker.map = mapView;
                self.generatePOIItems(String(format: "%d", index), position: marker.position, id: index)
            }
        }
        
        mapView.clear();
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(userLatitude), longitude: Double(userLongitude)));
        marker.userData = true;
        let icon = imageWithImage(image: UIImage(named: "ic_my_location")!, scaledToSize: CGSize(width: 40, height: 40)).withRenderingMode(.alwaysTemplate);
        let iconView = UIImageView(image: icon);
        iconView.tintColor = UIColor(named: "mainColorLight");
        marker.iconView = iconView;
        marker.map = mapView;
        
        clusterManager.cluster();
    }
    
    func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator();
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                    clusterIconGenerator: iconGenerator)
        renderer.delegate = self;
        self.clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                                          renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
          zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.animate(with: update)
        return true
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        
        if marker.userData is POIItem {
            
            let icon = imageWithImage(image: markerIcon!, scaledToSize: CGSize(width: 40, height: 40)).withRenderingMode(.alwaysTemplate);
            let iconView = UIImageView(image: icon);
            iconView.tintColor = UIColor(named: "mainColor");
            marker.iconView = iconView;
        } else if let cluster = marker.userData as? GMUCluster {
            let icon = ClusterIcon(frame: CGRect(x: 0, y: 0, width: 40, height: 40), amountOfItems: cluster.items.count);
            marker.iconView = icon;
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        guard let item = marker.userData as? POIItem else {
            return nil;
        }
        
        guard let index = item.id else {
            return nil;
        };
        marker.tracksInfoWindowChanges = true;
        guard let eventId = hobbyData[index].id else {
            return UIView();
        }
        let infoWindow = MapInfoView(frame: CGRect(x: 0, y: 0, width: 160, height: 190), onPress: {
            self.navigateToDetailViewWithindex(eventId);
        });
        if let hobby = hobbyData[index].hobby {
            infoWindow.setImage(urlString: hobby.image, completition: {
                marker.tracksInfoWindowChanges = false;
                self.imageCache[index] = infoWindow.imageView.image;
            });
            infoWindow.imageView.hero.id = "image" + String(index);
            infoWindow.titleLabel.text = hobby.name;
            infoWindow.dateLabel.text = hobbyData[index].startDate;
            infoWindow.contentView.hero.id = "container";
        }
        return infoWindow;
    }
    
    func generatePOIItems(_ accessibilityLabel: String, position: CLLocationCoordinate2D, id: Int) {
        let item = POIItem(position: position, name: accessibilityLabel, id: id);
        self.clusterManager.add(item)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let id = (marker.userData as! POIItem).id {
            navigateToDetailViewWithindex(id);
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.filters {
            guard let filterModal = segue.destination as? FilterViewController else {
                return
            }
            filterModal.modalDelegate = self
        }
    }
    
}
