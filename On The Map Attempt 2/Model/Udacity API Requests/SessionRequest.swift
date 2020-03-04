//
//  SessionRequest.swift
//  On The Map Attempt 2
//
//  Created by Diana Liang on 3/2/20.
//  Copyright © 2020 Diana Liang. All rights reserved.
//

import Foundation

struct SessionRequest: Codable {
    let udacity: UdacityAccount
}

struct UdacityAccount: Codable {
    let username: String
    let password: String
}
