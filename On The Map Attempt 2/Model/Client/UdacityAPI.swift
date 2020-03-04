//
//  UdacityAPI.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation

class UdacityAPI {
    
    struct userInfo {
        static var isUserRegistered = false
        static var userId = ""
        static var userFirstName = ""
        static var userLastName = ""
    }
    
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
                print("failed at the catch statement")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
            
            print(String(data: newData, encoding: .utf8)!)
        }
        task.resume()
    }
    
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
            
            print(String(data: newData, encoding: .utf8)!)
        }
        task.resume()
    }
    
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

                print("user first name within the getUserData \(responseObject.firstName)")
            } catch {
                return
            }
        }
        task.resume()
    }
    
    
}
