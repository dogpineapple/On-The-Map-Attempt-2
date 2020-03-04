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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        // Get the student location data and put into a dictionary
        getStudentLocations()
        
        if ParseAPI.userPin.objectId != "" {
            // CODE TO POST THE PIN THE USER JUST MADE REEEEEEEE
        }
    }
    
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        performSegue(withIdentifier: "createPinFromMapView", sender: nil)
    }
    
    @IBAction func refreshData(_ sender: Any) {
        self.mapView.removeAnnotations(self.annotations)
        getStudentLocations()
    }
    
    @IBAction func logout(_ sender: Any) {
        UdacityAPI.deleteSession { (response, error) in }
        performSegue(withIdentifier: "unwindSegueToLoginViewController", sender: nil)
    }
    
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
            print("getStudentLocations has been run")
            self.mapView.addAnnotations(self.annotations)
        }
    }
}


