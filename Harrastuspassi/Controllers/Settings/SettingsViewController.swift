//
//  SettingsViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 05/09/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import CoreLocation

@IBDesignable class SettingsViewController: UIViewController, LocationListDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var locationUsageAllowed: Bool = UserDefaults.standard.bool(forKey: DefaultKeys.Location.isAllowed);
    
    var savedLocations = [CoordinateData]();
    var selectedLocation = CoordinateData(lat: 0, lon: 0);
    let feedbackGenerator = UISelectionFeedbackGenerator();
    
    @IBOutlet weak var allowLocationUsageButton: UIButton!
    @IBOutlet weak var pickLocationButton: UIButton!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var locationListContainer: UIView!
    @IBOutlet weak var allowLocationSwitch: UISwitch!
    @IBOutlet weak var locationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil);
        locationTableView.delegate = self;
        locationTableView.dataSource = self;
        willEnterForeground();
        
        let defaults = UserDefaults.standard;
        
        guard let savedLocationsData = defaults.object(forKey: DefaultKeys.Location.savedLocations) as? Data else {
            print("fail1")
            return;
        }
        
        guard let savedLocations = try? PropertyListDecoder().decode(Array<CoordinateData>.self, from: savedLocationsData) else {
            print("fail2")
            return;
        }
        self.savedLocations = savedLocations.reversed();
        print(self.savedLocations)
        
        guard let selectedLocationData = defaults.object(forKey: DefaultKeys.Location.selectedLocation) as? Data else {
            return;
        }
        
        if let selectedLocation = try? PropertyListDecoder().decode(CoordinateData.self, from: selectedLocationData) {
            
            self.selectedLocation = selectedLocation;
        }
        locationTableView.reloadData();
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func switchValueChanged(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        if allowLocationSwitch.isOn {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                appDelegate.requestLocationAuth();
            }
            else if CLLocationManager.authorizationStatus() == .denied {
                allowLocationSwitch.isOn = false;
            } else {
                locationUsageAllowed = true;
                fadeOutLocationComponents()
                appDelegate.startLocationServices();
            }
        } else {
            locationUsageAllowed = false;
            appDelegate.disableLocationServices();
            fadeInLocationComponents()
        }
    }
    
    func fadeOutLocationComponents() {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickLocationButton.alpha = 0.3;
            self.locationListContainer.alpha = 0.3;
        }, completion: nil);
    }
    func fadeInLocationComponents() {
        self.pickLocationButton.alpha = 0.3;
        self.locationListContainer.alpha = 0.3;
        UIView.animate(withDuration: 0.3, animations: {
            self.pickLocationButton.alpha = 1;
            self.locationListContainer.alpha = 1;
        });
    }
    
    @IBAction func openSettingsButtonPressed(_ sender: Any) {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    @objc func willEnterForeground() {
        let locationUsageAllowed: Bool = UserDefaults.standard.bool(forKey: DefaultKeys.Location.isAllowed);
        let locationAuthStatusIsAllowed = CLLocationManager.authorizationStatus() != .denied;
        
        
        allowLocationSwitch.isOn = locationUsageAllowed;
        
        allowLocationSwitch.isEnabled = locationAuthStatusIsAllowed;
        
        allowLocationUsageButton.isHidden = locationAuthStatusIsAllowed;
        
        if locationUsageAllowed {
            pickLocationButton.alpha = 0.3;
            locationListContainer.alpha = 0.3;
        } else {
            pickLocationButton.alpha = 1;
            locationListContainer.alpha = 1;
        }
    }
    
    func didSaveLocation(_ coordinates: [CoordinateData]) {
        savedLocations = coordinates.reversed();
        selectLocation(location: savedLocations[0]);
        locationTableView.reloadData();
        locationTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocations.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let locationForIndex = savedLocations[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationTableViewCell;
        cell.accessoryType = .none;
        cell.selectionStyle = .blue;
        cell.addressLabel.adjustsFontSizeToFitWidth = true;
        let bgView = UIView(frame: cell.frame);
        bgView.backgroundColor = Colors.bgMain;
        cell.selectedBackgroundView = bgView;
        cell.tintColor = .green;
        if self.selectedLocation.lat == savedLocations[indexPath.row].lat && self.selectedLocation.lon == savedLocations[indexPath.row].lon {
            cell.accessoryType = .checkmark;
        }
        cell.addressLabel.text =
            locationForIndex.streetName + " " +
            locationForIndex.streetNumber + ", " +
            locationForIndex.zipCode + " " +
            locationForIndex.city;
        cell.cityLabel.text = locationForIndex.city.uppercased();
        return cell;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! SettingsMapViewController;
        destination.locationListDelegate = self;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard;
        guard let selectedLocationData = defaults.object(forKey: DefaultKeys.Location.selectedLocation) as? Data else {
            return;
        }
        
        if let selectedLocation = try? PropertyListDecoder().decode(CoordinateData.self, from: selectedLocationData) {
            
            func shouldSelect() -> Bool {
                if selectedLocation.lat == savedLocations[indexPath.row].lat && selectedLocation.lon == savedLocations[indexPath.row].lon {
                    return true;
                }
                return false;
            }
            
            if shouldSelect() {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none);
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LocationTableViewCell;
        cell.accessoryType = .none;
        cell.addressLabel.textColor = .black
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setSelectedStyleTo(tableView, indexPath: indexPath);
        selectLocation(location: savedLocations[indexPath.row]);
        let cell = tableView.cellForRow(at: indexPath) as! LocationTableViewCell;
        cell.addressLabel.textColor = .white;
        feedbackGenerator.selectionChanged();
        
    }
    
    func selectLocation(location: CoordinateData) {
        self.selectedLocation = location;
    }
    
    func setSelectedStyleTo(_ tableView: UITableView, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LocationTableViewCell;
        cell.accessoryType = .checkmark;
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let defaults = UserDefaults.standard;
        defaults.set(try? PropertyListEncoder().encode(selectedLocation), forKey: DefaultKeys.Location.selectedLocation);
        defaults.set(locationUsageAllowed, forKey: DefaultKeys.Location.isAllowed)
        var tmpLocations = savedLocations.reversed().filter {
            $0.lat != selectedLocation.lat && $0.lon != selectedLocation.lon
        }
        if !locationUsageAllowed {
            defaults.set(selectedLocation.lat, forKey: DefaultKeys.Location.lat);
            defaults.set(selectedLocation.lon, forKey: DefaultKeys.Location.lon);
        }
        tmpLocations.append(selectedLocation);
        defaults.set(try? PropertyListEncoder().encode(tmpLocations), forKey: DefaultKeys.Location.savedLocations);
        self.dismiss(animated: true, completion: nil);
    }
}
