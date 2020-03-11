//
//  CreatePinViewController.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation
import UIKit

class CreatePinViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var userLocationTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // Cancel will dismiss the view and return to the map view controller.
    @IBAction func cancelPinCreation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Checks if the user has entered a location. If nothing has been entered, it will show an alert. Otherwise, it will perform the segue to the next view controller
    @IBAction func goToSubmitViewController(_ sender: Any) {
        if userLocationTextField.text != "" {
            performSegue(withIdentifier: "goToAddURL", sender: nil)
        } else {
            showAlert(message: "Please enter a location.")
        }
    }
    
    // Sends the inputed location to the next view controller so the location can be displayed on the map view in the submit pin VC and posted to the Parse API
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddURL" {
            let destinationVC = segue.destination as! SubmitCreatedPinViewController
            destinationVC.findLocation = userLocationTextField.text
        }
    }
    
    // MARK: Alerts
    func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Something went wrong.", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}
