//
//  ParseAPI.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation

class ParseAPI {
    
    struct userPin {
        static var objectId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/StudentLocation"

        case getStudentLocations
        case postStudentLocation
        case updateStudentLocation
        
        var stringValue:String {
            switch self {
            case .getStudentLocations:
                return Endpoints.base
            case .postStudentLocation:
                return Endpoints.base
            case .updateStudentLocation:
                return Endpoints.base + "/\(userPin.objectId)"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getStudentLocations (completion: @escaping ([StudentInformation], Error?) -> Void) {
        let request = URLRequest(url: Endpoints.getStudentLocations.url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(StudentResults.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject.results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
                
            }
        }
        task.resume()
    }
    
    // MARK: POST Student Location (Create a new pin)
    class func postStudentLocation (uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (String, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.postStudentLocation.url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostStudentPin(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: Float(latitude), longitude: Float(longitude))
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion("", error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PostStudentLocationResponse.self, from: data)
                userPin.objectId = responseObject.objectId
                DispatchQueue.main.async {
                    completion(responseObject.objectId, nil)
                }
            } catch {
                DispatchQueue.main.async {
                completion("", error)
                }
            }
            // TO DO: Remove print statement
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
    // MARK: PUT Student Location (Updating existing student location)
    class func putStudentLocation (uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Float, longitude: Float, completion: @escaping (String, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.updateStudentLocation.url)
        
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = PostStudentPin(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion("", error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(UpdateStudentLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject.updatedAt, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion("", error)
                }
            }
        }
        task.resume()
    }
    
    
    
}
