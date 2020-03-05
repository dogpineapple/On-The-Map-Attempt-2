//
//  UdacityAPI.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation

class UdacityAPI {
    // userInfo will allow the user to GET a random first and last name. Saving the userId (account key) to access the GET Public User Data Endpoint
    struct userInfo {
        static var isUserRegistered = false
        static var userId = ""
        static var userFirstName = ""
        static var userLastName = ""
    }
    // MARK: Endpoints for the network requests
    enum Endpoints {
       
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case postSession
        case deleteSession
        case getUserData
        
        var stringValue:String {
            switch self {
            case .postSession:
                return Endpoints.base + "/session"
            case .deleteSession:
                return Endpoints.base + "/session"
            case .getUserData:
                return Endpoints.base + "/users" + "/\(userInfo.userId)"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    // Authenticate user login credentials and produce a session id/account key.
    class func postSession (udacity: UdacityAccount, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.postSession.url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = SessionRequest(udacity: udacity)
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }

            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(SessionResponse.self, from: newData)
                userInfo.userId = responseObject.account.key
                userInfo.isUserRegistered = responseObject.account.registered
                DispatchQueue.main.async {
                    completion(userInfo.isUserRegistered, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    // Delete session when user logs out.
    class func deleteSession(completion: @escaping (String, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.deleteSession.url)
        
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion("", error)
                }
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(Session.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject.id, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion("", error)
                }
            }
        }
        task.resume()
    }
    
    // fetches random user data to use as first and last name for the user's location pin post.
    class func getUserData() {
        let request = URLRequest(url: Endpoints.getUserData.url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(UserRealName.self, from: newData)
                userInfo.userFirstName = responseObject.firstName
                userInfo.userLastName = responseObject.lastName
            } catch {
                return
            }
        }
        task.resume()
    }
}
