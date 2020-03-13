
//
//  MapTableViewController.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation
import UIKit

class MapTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    
    var selectedIndex = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
    }
    
    // The number of rows in the table will equal to the number of elements are within studentData.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.students.count
    }
    
    // Populates the cell with the data from studentData array.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")
        let locations = StudentModel.students[indexPath.row]
        
        cell?.textLabel?.text = "\(locations.firstName) \(locations.lastName)"
        cell!.detailTextLabel?.text = locations.mediaURL
        return cell!
    }
    
    // When the student taps on a cell, it will open the url on the row that the user selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let selectedURL = StudentModel.students[indexPath.row]
        let app = UIApplication.shared
        app.openURL(URL(string: selectedURL.mediaURL)!)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // Checks if the objectId (pin) exists, if it does, it will ask the user if they want to overwrite their existing pin in an alert view. Otherwise, it brings them to the create pin view controller.
    @IBAction func addPin(_ sender: Any) {
        if ParseAPI.userPin.objectId != "" {
            showAlert(message: "User pin currently exists. Confirm overwrite to change pin.")
        } else {
            performSegue(withIdentifier: "createPinFromTableView", sender: nil)
        }
    }
    
    // Refreshes the table cells with new data.
    @IBAction func refreshData(_ sender: Any) {
        StudentModel.students = [StudentInformation]()
        getStudentLocations()
        tableView.reloadData()
    }
    
    // Logs out the user and sends them to the login page.
    @IBAction func logout(_ sender: Any) {
        UdacityAPI.deleteSession { (response, error) in }
        performSegue(withIdentifier: "unwindSegueToLoginViewController", sender: nil)
    }
    
    // Gets the list of students' information and adds them to the student Data array to populate the cells.
    func getStudentLocations() {
        ParseAPI.getStudentLocations { (students, error) in
            for aStudent in students {
                let student = StudentInformation(objectId: aStudent.objectId, uniqueKey: aStudent.uniqueKey, firstName: aStudent.firstName, lastName: aStudent.lastName, mapString: aStudent.mapString, mediaURL: aStudent.mediaURL, latitude: aStudent.latitude, longitude: aStudent.longitude, createdAt: aStudent.createdAt, updatedAt: aStudent.updatedAt)
                StudentModel.students.append(student)
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: Alerts
    func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Overwrite existing pin?", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "createPinFromTableView", sender: nil)
        }))

        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
    }
}
