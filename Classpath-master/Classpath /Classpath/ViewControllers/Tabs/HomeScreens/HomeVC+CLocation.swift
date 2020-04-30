//
//  HomeVC+CLocation.swift
//  Classpath
//
//  Created by coldfin_lb on 8/10/18.
//  Copyright © 2018 coldfin_lb. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth

extension HomeVC:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            
        }else if status == .denied
        {
            self.stopAnimating()
            print("Location permission denied.")
            didFindMyLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        locationCoordinate = currentLocation?.coordinate
        snapUtils.latCurrent = CLLocation(latitude:  self.locationCoordinate.latitude, longitude:  self.locationCoordinate.longitude)
        locationManager.stopUpdatingLocation()
        didFindMyLocation = true
        
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        
        print(self.locationCoordinate.latitude)
        print(self.locationCoordinate.latitude)
        
        // ADDED BY ANKIT
        
        guard let uid=Auth.auth().currentUser?.uid else{
            return
        }
        
        let parameter=NSMutableDictionary()
        parameter.setValue(self.locationCoordinate.latitude, forKey:keyLat)
        parameter.setValue(self.locationCoordinate.longitude, forKey:keyLong)
        let userInstance=self.ref.child(nodeUsers).child(uid)
        userInstance.updateChildValues(parameter as! [AnyHashable : Any])
        
        fetchCountryAndCity(location: location) { country, city in
            print("country:", country)
            print("city:", city)
            self.stopAnimating()
            utils.userCity = city
            self.navigationItem.title = "Explore fitness in \(city)"
         //   self.lblTitleText.text = "Add your fitness business OR book a session with some of the best trainers in \(city)"
        }
    }
    
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                completion(country, city)
            }
        }
    }
}
