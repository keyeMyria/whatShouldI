//
//  MapViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/5/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import MapKit
import Localide

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var place: Place!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.delegate = self
        navItem.title = place.name
        
        print("place = \(place)")
        updateLocation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    func updateLocation() {
        mapView.removeAnnotation(place)
        mapView.addAnnotation(place)
        
        let theRegion = region(for: place)
        mapView.setRegion(theRegion, animated: true)
        
        mapView.selectAnnotation(mapView.annotations[0], animated: true)
    }
    
    func region(for annotation: MKAnnotation) -> MKCoordinateRegion {
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
     
        return mapView.regionThatFits(region)
    }
    
    @objc func showPlaceDetails(sender: UIButton) {
        let myAlert = UIAlertController(title: "Options", message: "", preferredStyle: .alert)
        let directionsAlert = UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
            Localide.sharedManager.promptForDirections(toLocation: self.place.coordinate, onCompletion: nil)
        })
        let detailsAlert = UIAlertAction(title: "Details", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "showDetailFromMap", sender: sender)
        })
        let cancelAlert = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            
        })
        myAlert.addAction(directionsAlert)
        myAlert.addAction(detailsAlert)
        myAlert.addAction(cancelAlert)
        
        if let popoverController = myAlert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(myAlert, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is Place else {
            return nil
        }
        
        let identifier = "Place"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = true
            
            if place.open_now! {
                pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            }
            else {
                pinView.pinTintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1)
            }
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showPlaceDetails), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        }
        
        
        return annotationView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetailFromMap" {
            if let destination = segue.destination as? PlaceDetailsViewController {
                destination.place = place
            }
        }
     
    }
    

}
