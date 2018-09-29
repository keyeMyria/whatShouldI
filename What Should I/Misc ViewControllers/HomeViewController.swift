//
//  ViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 1/31/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import CoreLocation
import ReachabilityLib

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationOutlet: UIBarButtonItem!
    @IBOutlet weak var pinOutlet: UIBarButtonItem!
    @IBOutlet weak var myLocationOutlet: UIBarButtonItem!
    @IBOutlet weak var goPremiumOutlet: UIBarButtonItem!
    
    var choiceType: String!
    
    var myLocationButton = UIButton(type: .system)
    var locationManager: CLLocationManager!
    lazy var geocoder = CLGeocoder()
    
    let reachability = Reachability()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        
        goPremiumOutlet.tintColor = .orange
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = .black
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults.bool(forKey: "premium") {
            goPremiumOutlet.title = "Status: Premium"
            goPremiumOutlet.isEnabled = false
        }
        
        if !reachability.isInternetAvailable(){
            alert(message: "Please check your internet connection.", title: "Internet connection is not available")
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myLocationButton)
        
        if defaults.bool(forKey: "hasLocation") {
            if let myLocation = defaults.dictionary(forKey: "myLocation") {
                let location = CLLocation(latitude: myLocation["lat"] as! CLLocationDegrees, longitude: myLocation["long"] as! CLLocationDegrees)
                reverseGeocode(location: location)
            }
        }
        else {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            determineMyCurrentLocation()
        }
        
    }
    
    func setupLocationButton(title: String!) {
        myLocationButton.setImage(UIImage(named: "pin2"), for: .normal)
        myLocationButton.imageView?.clipsToBounds = true
        myLocationButton.imageView?.contentMode = .scaleAspectFit
        myLocationButton.setTitle(title, for: .normal)
        myLocationButton.titleLabel?.textAlignment = .left
        myLocationButton.titleLabel?.numberOfLines = 1
        myLocationButton.titleLabel?.sizeToFit()
        myLocationButton.addTarget(self, action: #selector(myLocationTapped), for: .touchUpInside)
        let imageFrame = myLocationButton.imageView!.frame
        print(imageFrame)
        let titleFrame = myLocationButton.titleLabel!.frame
        print(titleFrame)
        myLocationButton.imageEdgeInsets = UIEdgeInsetsMake(6, 0, 6, 0)
        myLocationButton.titleEdgeInsets = UIEdgeInsetsMake(0, -titleFrame.width/4, 0, 0)
        myLocationButton.tintColor = .orange
    }
    
    @objc func myLocationTapped(_ button: UIButton) {
        performSegue(withIdentifier: "toMyLocation", sender: button)
    }
    
    @IBAction func premiumPressed(_ sender: UIBarButtonItem) {
        let myAlert = UIAlertController(title: "Options", message: "", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Go Premium", style: .cancel) { _ in
            let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            tabbarVC.selectedIndex = 2
            self.present(tabbarVC, animated: true, completion: {
                let vc = tabbarVC.viewControllers![2] as! OtherViewController
                vc.purchase(purchase: .bingle)
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
        }
        
        myAlert.addAction(cancelAction)
        myAlert.addAction(yesAction)
        
        if let popoverController = myAlert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(myAlert, animated: true, completion: nil)
    }
    
    
    // MARK - Table View
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! HomeViewCell
        cell.backgroundColor = .clear
        
        cell.buttonAction.text = rowLabels[indexPath.row]
        cell.buttonAction.font = UIFont(name: "AnjaElianeaccent-Nornal", size: Env.iPad ? 30 : 20)
        
        let image = UIImage(named: rowLabels[indexPath.row])!
        cell.setPostedImage(image: image)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        choiceType = rowLabels[indexPath.row]
        performSegue(withIdentifier: "toFirstChoice", sender: self)
        
    }
    
    @IBAction func unwindToHomeViewController(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFirstChoice" {
            let destination = segue.destination as! MiniSettingsViewController
            destination.choiceType = choiceType
        }
    }


}

extension HomeViewController {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
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
            
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    
    func determineMyCurrentLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
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
                
                locationManager.startUpdatingLocation()
                //locationManager.startUpdatingHeading()
            }
        }
        else {
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
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.delegate = nil
        manager.stopUpdatingLocation()
        
        // Create Location
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let myLocation: Dictionary = ["lat" : NSNumber(value: userLocation.coordinate.latitude), "long": NSNumber(value: userLocation.coordinate.longitude)]
        defaults.set(true, forKey: "hasLocation")
        defaults.set(myLocation, forKey: "myLocation")
        
        // Geocode Location
        reverseGeocode(location: location)
    }
    
    func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                self.myLocationButton.setTitle("Unknown", for: .normal)
                return
            }
            
            if (error == nil) {
                // Place details
                let placemark = CLPlacemark(placemark: placemarks![0] as CLPlacemark)
                
                // City
                if placemark.locality != nil {
                    self.setupLocationButton(title: "\(placemark.locality!), \(placemark.administrativeArea!)")
                    //self.myLocationButton.setTitle("\(placemark.locality!), \(placemark.administrativeArea!)", for: .normal)
                }
                
                
            }
            else {
                self.myLocationButton.setTitle("Unknown", for :.normal)
                return
            }
        })
    }
}

