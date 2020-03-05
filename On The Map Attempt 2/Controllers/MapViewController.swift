//
//  MapViewController.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var annotations = [MKPointAnnotation]()

    
    //MARK: OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    // Before the view loads, the map pins will be removed and the annotations array will be cleared. We clear them because we want to reload for the recently posted student locations when the view is presented.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.delegate = self
        self.mapView.removeAnnotations(self.mapView.annotations)
        annotations.removeAll()
        // Get the student location data and put into a dictionary
        getStudentLocations()
    }
    
    // Creates the pins for each item in the annotations array.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // Style of the pin and sets the action to open the url when the pin's url is tapped.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    
    // Checks if the objectId (pin) exists, if it does, it will ask the user if they want to overwrite their existing pin in an alert view. Otherwise, it brings them to the create pin view controller.
    @IBAction func addPin(_ sender: Any) {
        if ParseAPI.userPin.objectId != "" {
            showAlert(message: "User pin currently exists. Confirm overwrite to change pin.")
        } else {
            performSegue(withIdentifier: "createPinFromMapView", sender: nil)
        }
    }
    
    // Refreshes the view.
    @IBAction func refreshData(_ sender: Any) {
        viewWillAppear(true)
    }
    
    // Logs the user out and goes back to the login page.
    @IBAction func logout(_ sender: Any) {
        UdacityAPI.deleteSession { (response, error) in }
        performSegue(withIdentifier: "unwindSegueToLoginViewController", sender: nil)
    }
    
    // gets the list of students' posted information
    func getStudentLocations() {
        ParseAPI.getStudentLocations { (studentInformation, error) in
            for dictionary in studentInformation {
                let lat = CLLocationDegrees(dictionary.latitude)
                let long = CLLocationDegrees(dictionary.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let firstName = dictionary.firstName
                let lastName = dictionary.lastName
                
                let mediaURL = dictionary.mediaURL
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                self.annotations.append(annotation)
            }
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    // MARK: Alerts
    func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Overwrite existing pin?", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "createPinFromMapView", sender: nil)
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}


