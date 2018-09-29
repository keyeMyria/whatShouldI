//
//  MyLocationViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/3/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import CoreLocation

class MyLocationViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var zipcodeTF: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var locationManager: CLLocationManager!
    lazy var geocoder = CLGeocoder()
    
    var userLocation: CLLocation?
    var locationDDict = Dictionary<String, NSNumber>()
    
    var city: String?
    var state: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        saveButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = aqua
        
        getLocationButton.layer.cornerRadius = getLocationButton.frame.height/2
        getLocationButton.layer.borderWidth = 2
        getLocationButton.layer.borderColor = UIColor.black.cgColor
        
        zipcodeTF.layer.cornerRadius = zipcodeTF.frame.height/2
        zipcodeTF.delegate = self
        zipcodeTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        zipcodeTF.returnKeyType = .done
        
        saveButton.layer.cornerRadius = saveButton.layer.frame.height/2
        saveButton.layer.borderWidth = 2
        disableSave()
    }
    
    func enableSave() {
        saveButton.layer.borderColor = UIColor.black.cgColor
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.isEnabled = true
    }
    
    func disableSave() {
        saveButton.layer.borderColor = UIColor.lightGray.cgColor
        saveButton.setTitleColor(.lightGray, for: .normal)
        saveButton.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if newLength < 5 {
            self.disableSave()
        }
        return newLength <= 5 // Bool
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.count) == 5 {
            self.locationFromZipcode(zipcode: textField.text!)
        }
        
    }
    
    @IBAction func getMyLocation(_ sender: UIButton) {
        disableSave()
        determineMyCurrentLocation()
    }
    
    @IBAction func saveInfo(_ sender: UIButton) {
        locationDDict = ["lat" : NSNumber(value: userLocation!.coordinate.latitude), "long": NSNumber(value: userLocation!.coordinate.longitude)]
        defaults.set(locationDDict, forKey: "myLocation")
        
        let myAlert = UIAlertController(title: "New Location: \(city!), \(state!)", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        })
        myAlert.addAction(okAction)
        
        if let popoverController = myAlert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(myAlert, animated: true)
    }
    
    func determineMyCurrentLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined:
                print("first time")
            case .restricted, .denied:
                let myAlert = UIAlertController(title: "Request", message: "Please enable Location Services in Settings to use this service", preferredStyle: UIAlertControllerStyle.alert)
                let yesAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default){ (ACTION) in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
                let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
                
                myAlert.addAction(yesAction)
                myAlert.addAction(noAction)
                
                if let popoverController = myAlert.popoverPresentationController {
                    popoverController.sourceView = self.view
                }
                self.present(myAlert, animated: true, completion: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                self.getLocationButton.isEnabled = false
                self.saveButton.isEnabled = false
                
                locationManager.startUpdatingLocation()
                //locationManager.startUpdatingHeading()
            }
        } else {
            let myAlert = UIAlertController(title: "Request", message: "Enable Location Services?", preferredStyle: UIAlertControllerStyle.alert)
            let yesAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default){ (ACTION) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            let noAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            
            myAlert.addAction(yesAction)
            myAlert.addAction(noAction)
            
            if let popoverController = myAlert.popoverPresentationController {
                popoverController.sourceView = self.view
            }
            self.present(myAlert, animated: true, completion: nil)
            
            getLocationButton.isEnabled = true
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.delegate = nil
        manager.stopUpdatingLocation()
        
        // Create Location
        let location = CLLocation(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        
        // Geocode Location
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            
            if (error != nil) {
                self.locationLabel.text = "Could not determine location"
                return
            }
            
            if (error == nil) {
                // Place details
                let placemark = CLPlacemark(placemark: placemarks![0] as CLPlacemark)
                
                // City
                if placemark.locality != nil {
                    self.locationLabel.text = "Location: \(placemark.locality!), \(placemark.administrativeArea!)"
                    self.city = placemark.locality!
                    self.state = placemark.administrativeArea!
                }
                // Zip code
                if (placemark.postalCode != nil) && (placemark.administrativeArea != nil) {
                    self.zipcodeTF.text = placemark.postalCode
                }
            }
            else {
                self.locationLabel.text = "Could not determine location"
                return
            }
            self.getLocationButton.isEnabled = true
            self.enableSave()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func locationFromZipcode(zipcode: String) {
        self.disableSave()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(zipcode) { (placemarks, error) -> Void in
            
            if (error != nil) {
                self.locationLabel.text = "Could not determine location"
                return
            }
            
            if (error == nil) {
                // Place details
                let placemark = CLPlacemark(placemark: placemarks![0] as CLPlacemark)
                
                // City
                if placemark.locality != nil {
                    self.locationLabel.text = "Location: \(placemark.locality!), \(placemark.administrativeArea!)"
                    self.city = placemark.locality!
                    self.state = placemark.administrativeArea!
                }
                // Zip code
                if (placemark.postalCode != nil) && (placemark.administrativeArea != nil) {
                    //self.zipcodeTF.text = placemark.postalCode
                }
                
                if let location = placemark.location {
                    self.userLocation = location
                    self.enableSave()
                }
            }
            else {
                self.locationLabel.text = "Could not determine location"
                return
            }
            
        }
    }
    
    

}
