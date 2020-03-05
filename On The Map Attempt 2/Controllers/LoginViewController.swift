//
//  LoginViewController.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    
    // MARK: OUTLETS
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: ACTIONS
    // Checks if the email and password text field is entered or not. If empty, show alert.
    @IBAction func verifyLogin(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            let account = UdacityAccount.init(username: emailTextField.text ?? "", password: passwordTextField.text ?? "")
            UdacityAPI.postSession(udacity: account, completion: handleLogin(success:error:))
        } else {
            showLoginFailure(message: "Please enter your Udacity username and password.")
        }
    }
    
    // Unwind to Login VC when user signs out.
    @IBAction func unwindToLoginViewController(segue:UIStoryboardSegue) { }
    
    // Opens the Udacity sign up page.
    @IBAction func openSignUpURL(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://auth.udacity.com/sign-up")!)
    }
    
    // If the login credentials were wrong, then success will be false and will show an alert.
    // If login was a success, it will show the map view controller and also clears the email and password textfield for the next time the login view controller is displayed.
    func handleLogin(success: Bool, error: Error?) {
        if success {
            performSegue(withIdentifier: "loginSuccess", sender: nil)
            emailTextField.text = ""
            passwordTextField.text = ""
        } else {
            showLoginFailure(message: "Incorrect username or password. Please try again.")
        }
    }
    
    // MARK: Alerts
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
