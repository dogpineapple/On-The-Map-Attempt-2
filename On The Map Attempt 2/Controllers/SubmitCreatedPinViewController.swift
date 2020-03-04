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
    let uniqueKey: String = "1234"
    
    //MARK: OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserGeocodeLocation().getCoordinate(addressString: findLocation!) { (result, error) in
            self.userLat = result.latitude
            self.userLong = result.longitude
            let userPin = MKPointAnnotation()
            userPin.coordinate = CLLocationCoordinate2D(latitude: self.userLat, longitude: self.userLong)
            self.mapView.addAnnotation(userPin)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UdacityAPI.getUserData()
    }
    
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
    
    @IBAction func submitPin(_ sender: Any) {
        let mediaURL = urlTextField.text
        ParseAPI.postStudentLocation(uniqueKey: uniqueKey, firstName: UdacityAPI.userInfo.userFirstName, lastName: UdacityAPI.userInfo.userLastName, mapString: findLocation, mediaURL: mediaURL!, latitude: userLat, longitude: userLong) { (response, error) in
            
            print("please print lol \(UdacityAPI.userInfo.userFirstName)")
        }
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.popToViewController(destinationVC, animated: true)
    }

}
