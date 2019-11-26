//
//  SettingsMapViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 09/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps

class SettingsMapViewController: UIViewController, GMSMapViewDelegate {
    
    var locationSelected = false;
    var selectedLocation = CLLocationCoordinate2D();
    var locationListDelegate: LocationListDelegate!;
    
    @IBOutlet weak var saveSelectedLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let finland = GMSCameraPosition.camera(withLatitude: 61.9241,
                                               longitude: 25.7482,
                                               zoom: 6)
        
        mapView.delegate = self;
        mapView.camera = finland;
        
        saveSelectedLocationButton.alpha = 0.0;
        saveSelectedLocationButton.isEnabled = false;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barTintColor = UIColor(named: "mainColor");
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white];
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barTintColor = UIColor.white;
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "mainColor") ?? UIColor.black];
            
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
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate);
        self.mapView.clear();
        let marker = GMSMarker(position: coordinate);
        marker.title = "Valittu sijainti";
        marker.map = mapView;
        locationSelected = true;
        selectedLocation = coordinate;
        UIView.animate(withDuration: 0.3) {
            self.saveSelectedLocationButton.alpha = 1;
        }
        saveSelectedLocationButton.isEnabled = true;
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func saveLocation(_ sender: Any) {
        
        let geocoder = CLGeocoder();
        
        geocoder.reverseGeocodeLocation(CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude), completionHandler: self.dismissalActions)
        
    }
    
    func dismissalActions(placemarks: [CLPlacemark]?, error: Error?) {
        
        guard let pms = placemarks else {
            self.navigationController?.popViewController(animated: true);
            return;
        }
        
        let placemark = pms[0];
        print(placemark);
        let defaults = UserDefaults.standard;
        var coordinate = CoordinateData(lat: CFloat(selectedLocation.latitude), lon: CFloat(selectedLocation.longitude));
        if let country = placemark.country {
            coordinate.country = country;
        }
        if let address = placemark.thoroughfare {
            coordinate.streetName = address;
        }
        if let zipCode = placemark.postalCode {
            coordinate.zipCode = zipCode;
        }
        if let streetNumber = placemark.subThoroughfare {
            coordinate.streetNumber = streetNumber;
        }
        if let city = placemark.locality {
            coordinate.city = city;
        }
        if error == nil {
            coordinate.geoCodingCompleted = true;
        }
        var newLocations = [coordinate];
        
        guard let savedLocationsData = defaults.object(forKey: DefaultKeys.Location.savedLocations) as? Data else {
            locationListDelegate.didSaveLocation(newLocations);
            self.navigationController?.popViewController(animated: true);
            return;
        }
        
        guard let savedLocations = try? PropertyListDecoder().decode(Array<CoordinateData>.self, from: savedLocationsData) else {
            print("fail3")
            return;
        }
        newLocations = savedLocations;
        
        newLocations.append(coordinate);
        
        if newLocations.count > 5 {
            newLocations.removeFirst();
        }
        locationListDelegate.didSaveLocation(newLocations);
        print("wtf")
        self.navigationController?.popViewController(animated: true);
    }
}
