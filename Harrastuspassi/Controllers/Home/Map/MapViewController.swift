//
//  MapViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 19/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import Hero

class MapViewController: UIViewController, ModalDelegate, GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private var clusterManager: GMUClusterManager!
    
    var hobbyData = [HobbyEventData]();
    var filters = Filters();
    var imageCache = Dictionary<Int, UIImage>();
    var markerIcon = UIImage(named:"ic_room")?.withRenderingMode(.alwaysTemplate);
    var hobbies: [HobbyData] = [];
    var searchTerm: String? = "";
    
    
    // MARK: - Initialization
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        createMarkers(data: hobbies, mapView: mapView)
        
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
        let defaults = UserDefaults.standard;
        let lat = defaults.float(forKey: DefaultKeys.Location.lat);
        let lon = defaults.float(forKey: DefaultKeys.Location.lon);
        let finland = GMSCameraPosition.camera(withLatitude: Double(lat),
                                               longitude: Double(lon),
                                               zoom: 10);
        mapView.camera = finland;
        updateData();
        navigationController?.delegate = self;
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
            guard let response = try? JSONDecoder().decode(HobbyEventResponse.self, from: fetchedData)
                else {
                    return
            }
            guard let eventData = response.results else {return};
            DispatchQueue.main.async(execute: {() in
                if(eventData.count == 0) {
                    return;
                } else {
                    self.hobbyData = eventData.uniques;
                    
                    self.hobbyData.forEach { event in
                        if let hobby = event.hobby {
                            self.hobbies.append(hobby);
                        }
                    }
                    self.hobbies = self.hobbies.uniques;
                    self.createMarkers(data: self.hobbies, mapView: self.mapView);
                }
            })
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "location_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "organizer_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "exclude_past_events", value: "true"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "page_size", value: "500"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "max_distance", value: String("50")));
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
        if let search = searchTerm {
            urlComponents?.queryItems?.append(URLQueryItem(name: "search", value: search));
        }

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
    func createMarkers(data: [HobbyData], mapView: GMSMapView) {
        
        mapView.clear();
        
        let defaults = UserDefaults.standard;
        let userLongitude = defaults.float(forKey: DefaultKeys.Location.lon);
        let userLatitude = defaults.float(forKey: DefaultKeys.Location.lat);

        clusterManager.clearItems();
        
        for (index, hobby) in data.enumerated() {
            if let location = hobby.location, let id = location.id, let lat = location.coordinates?.coordinates?[1], let lon = location.coordinates?.coordinates?[0] {
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(lat)), longitude: CLLocationDegrees(lon)));
                let markerView = UIImageView(image: markerIcon);
                marker.iconView = markerView;
                marker.map = mapView;
                self.generatePOIItems(String(format: "%d", index), position: marker.position, id: id)
            }
        }
        
        mapView.clear();
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(userLatitude), longitude: Double(userLongitude)));
        marker.userData = true;
        let icon = imageWithImage(image: UIImage(named: "ic_my_location")!, scaledToSize: CGSize(width: 40, height: 40)).withRenderingMode(.alwaysTemplate);
        let iconView = UIImageView(image: icon);
        iconView.tintColor = UIColor(named: "accentPink");
        marker.iconView = iconView;
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
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
        
//        guard let item = marker.userData as? POIItem else {
//            return nil;
//        }
//
//        guard let index = item.id else {
//            return nil;
//        };
//        marker.tracksInfoWindowChanges = true;
//        guard let eventId = hobbyData[index].id else {
//            return UIView();
//        }
//        let infoWindow = MapInfoView(frame: CGRect(x: 0, y: 0, width: 160, height: 190), onPress: {
//            self.navigateToDetailViewWithindex(eventId);
//        });
//        if let hobby = hobbyData[index].hobby {
//            infoWindow.setImage(urlString: hobby.image, completition: {
//                marker.tracksInfoWindowChanges = false;
//                self.imageCache[index] = infoWindow.imageView.image;
//            });
//            infoWindow.imageView.hero.id = "image" + String(index);
//            infoWindow.titleLabel.text = hobby.name;
//            infoWindow.dateLabel.text = hobbyData[index].startDate;
//            infoWindow.contentView.hero.id = "container";
//        }
        return nil;
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let id = (marker.userData as? POIItem)?.id {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewController(withIdentifier: "hobbylistmodal") as! HobbyListModalViewController;
            vc.events = hobbyData.filter { event in
                event.hobby?.location?.id == id
            }
            let title = hobbyData.first { event in
                event.hobby?.location?.id == id
                }?.hobby?.location?.name;
            vc.titleText = title;
            mapView.preferredFrameRate = .conservative;
            vc.mapView = mapView;
            present(vc, animated: true, completion: nil);
        }
        return true;
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
