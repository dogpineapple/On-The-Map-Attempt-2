//
//  SubmitCreatedPinViewController.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SubmitCreatedPinViewController: UIViewController, MKMapViewDelegate {

    var findLocation: String!
    var userLat: Double!
    var userLong: Double!
    
    //MARK: OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Converts the location string into coordinates. The coordinates will be used to create an annotation for the pin.
        UserGeocodeLocation().getCoordinate(addressString: findLocation!) { (result, error) in
            self.userLat = result.latitude
            self.userLong = result.longitude
            let userPin = MKPointAnnotation()
            userPin.coordinate = CLLocationCoordinate2D(latitude: self.userLat, longitude: self.userLong)
            self.mapView.addAnnotation(userPin)
            
            self.mapViewDidFinishLoadingMap(self.mapView)
        }
    }
    
    // Gets random user data for a random first and last name. This information will be used to prepare for POST request for the pin creation.
    override func viewDidLoad() {
        super.viewDidLoad()
        UdacityAPI.getUserData()
    }
    
    // Creates the annotation pin.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
    
    // Zooms into the pin's location
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {

        let userPinToZoomInOn = CLLocationCoordinate2D(latitude: userLat, longitude: userLong)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: userPinToZoomInOn, span: span)
        mapView.setRegion(region, animated: true)

    }
    // Upon submit, it will make sure the url text field is not empty before posting/updating
    @IBAction func submitPin(_ sender: Any) {
        let mediaURL = urlTextField.text
        
        if mediaURL?.isEmpty ?? true {
            showAlert(message: "Please enter an URL")
        } else {
            // If objectId is not an empty string, then there is an existing pin. So we update the pin instead of posting a new one.
            if ParseAPI.userPin.objectId != "" {
                print("this is the objectId that wasnt, \(ParseAPI.userPin.objectId)")
                ParseAPI.putStudentLocation(uniqueKey: UdacityAPI.userInfo.userId, firstName: UdacityAPI.userInfo.userFirstName, lastName: UdacityAPI.userInfo.userLastName, mapString: findLocation, mediaURL: mediaURL!, latitude: userLat, longitude: userLong) { (response, error) in
                 }
            } else {
            // Otherwise, if objectId is an empty string, there is no existing pin. So we make a new pin.
                ParseAPI.postStudentLocation(uniqueKey: UdacityAPI.userInfo.userId, firstName: UdacityAPI.userInfo.userFirstName, lastName: UdacityAPI.userInfo.userLastName, mapString: findLocation, mediaURL: mediaURL!, latitude: userLat, longitude: userLong) { (response, error) in
                }
            }
            performSegue(withIdentifier: "goToTabBarController", sender: nil)
        }
    }
    
    // Cancel will bring the user back to the map view controller
    @IBAction func cancelPinCreation(_ sender: Any) {
        performSegue(withIdentifier: "goToTabBarController", sender: nil)
    }
    
    // MARK: Alerts
    func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }

    
}
