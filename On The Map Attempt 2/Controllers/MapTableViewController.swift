
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
    
    var studentData = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")
        let locations = studentData[indexPath.row]
        
        cell?.textLabel?.text = "\(locations.firstName) \(locations.lastName)"
        cell!.detailTextLabel?.text = locations.mediaURL
        return cell!
    }
    
    @IBAction func goToCreatePinView(_ sender: Any) {
        performSegue(withIdentifier: "CreatePinViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let selectedURL = studentData[indexPath.row]
        let app = UIApplication.shared
        app.openURL(URL(string: selectedURL.mediaURL)!)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    @IBAction func addPin(_ sender: Any) {
        performSegue(withIdentifier: "createPinFromTableView", sender: nil)
    }
    
    @IBAction func refreshData(_ sender: Any) {
        studentData = [StudentInformation]()
        getStudentLocations()
        tableView.reloadData()
    }
    @IBAction func logout(_ sender: Any) {
        UdacityAPI.deleteSession { (response, error) in }
        performSegue(withIdentifier: "unwindSegueToLoginViewController", sender: nil)
    }
    
    func getStudentLocations() {
        ParseAPI.getStudentLocations { (students, error) in
            for aStudent in students {
                let student = StudentInformation(objectId: aStudent.objectId, uniqueKey: aStudent.uniqueKey, firstName: aStudent.firstName, lastName: aStudent.lastName, mapString: aStudent.mapString, mediaURL: aStudent.mediaURL, latitude: aStudent.latitude, longitude: aStudent.longitude, createdAt: aStudent.createdAt, updatedAt: aStudent.updatedAt)
                self.studentData.append(student)
            }
            print("getStudentLocations has been run")
            self.tableView.reloadData()
        }
    }
}
