//
//  AppDelegate.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 12/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager();
    var locationServicesEnabled = false;


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(Config.GM_API_KEY)
        locationManager.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let defaults = UserDefaults.standard;
        defaults.set(locations.last?.coordinate.latitude, forKey: DefaultKeys.Location.lat);
        defaults.set(locations.last?.coordinate.longitude, forKey: DefaultKeys.Location.lon);
    }
    
    func requestLocationAuth() {
        locationManager.requestWhenInUseAuthorization();
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        let defaults = UserDefaults.standard;
        
        switch status {
            case .restricted, .denied:
                // Disable your app's location feature
                print(status)
                defaults.set(false, forKey: DefaultKeys.Location.isAllowed);
                break
            
            case .authorizedWhenInUse:
                // Enable only your app's when-in-use features.
                defaults.set(false, forKey: DefaultKeys.Location.isAllowed);
                break
            
            case .authorizedAlways:
                // Enable any of your app's location services.
                defaults.set(false, forKey: DefaultKeys.Location.isAllowed);
                break
            
            case .notDetermined:
                requestLocationAuth()
                break
            
            default:
                return
            }
    }
    
    func disableLocationServices() {
        locationManager.stopUpdatingLocation();
    }
    
    func startLocationServices() {
        locationManager.startUpdatingLocation();
    }
}

