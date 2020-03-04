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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func verifyLogin(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            let account = UdacityAccount.init(username: emailTextField.text ?? "", password: passwordTextField.text ?? "")
            print("this is the \(account) information printed")
            UdacityAPI.postSession(udacity: account, completion: handleLogin(success:error:))
        } else {
            showLoginFailure(message: "Please enter your Udacity username and password.")
        }
    }
    
    @IBAction func unwindToLoginViewController(segue:UIStoryboardSegue) { }
    
    func handleLogin(success: Bool, error: Error?) {
        if success {
            performSegue(withIdentifier: "loginSuccess", sender: nil)
            print(success)
        } else {
            print(success)
            showLoginFailure(message: "Incorrect username or password. Please try again.")
        }
    }

    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
