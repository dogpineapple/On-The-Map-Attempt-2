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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func cancelPinCreation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToSubmitViewController(_ sender: Any) {
        if userLocationTextField.text != "" {
            let destinationVC = storyboard?.instantiateViewController(withIdentifier: "SubmitCreatedPinViewController") as! SubmitCreatedPinViewController
            self.navigationController?.pushViewController(destinationVC, animated: true)
        } else {
            print("A location was not entered")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddURL" {
            let destinationVC = segue.destination as! SubmitCreatedPinViewController
            destinationVC.findLocation = userLocationTextField.text
            print("it should have a location entered \(destinationVC.findLocation)")
        }
    }
    
}
