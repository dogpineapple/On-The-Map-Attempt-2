//
//  ParseAPI.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation

class ParseAPI {
    
    // Save the objectId so the code can know whether the user has an existing pin to update or not.
    struct userPin {
        static var objectId = ""
    }
    // Endpoints for the network requests
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/StudentLocation"

        case getStudentLocations
        case postStudentLocation
        case updateStudentLocation
        
        var stringValue:String {
            switch self {
            case .getStudentLocations:
                return Endpoints.base + "?order=-updatedAt"
            case .postStudentLocation:
                return Endpoints.base
            case .updateStudentLocation:
                return Endpoints.base + "/\(userPin.objectId)"
            }
        }
        // returns the string type into an URL.
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // a function that should be called when doing a POST or PUT request
    class func taskForPOSTOrPUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, requestToMake: String, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = requestToMake
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    // MARK: GET Student Locations
    // Network request to get a list of other student's posted information (location, names, media url)
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
        let body = PostStudentPin(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: Float(latitude), longitude: Float(longitude))
        
        taskForPOSTOrPUTRequest(url: Endpoints.postStudentLocation.url, requestToMake: "POST", responseType: PostStudentLocationResponse.self, body: body) { (response, error) in
            
            if let response = response {
                userPin.objectId = response.objectId
                completion(response.objectId, nil)
            } else {
                completion("", error)
            }
        }
    }
    
    // MARK: PUT Student Location (Updating existing student location)
    class func putStudentLocation (uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (String, Error?) -> Void) {
         let body = PostStudentPin(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: Float(latitude), longitude: Float(longitude))
        
        taskForPOSTOrPUTRequest(url: Endpoints.updateStudentLocation.url, requestToMake: "PUT", responseType: UpdateStudentLocationResponse.self, body: body) { (response, error) in
            if let response = response {
                completion(response.updatedAt, nil)
            } else {
                completion("", error)
            }
        }
    }
}
