//
//  LoggedInUser.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 23/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import Foundation

class LoggedInUser {
    
    static var email: String = ""
    
    init(user: String){
        LoggedInUser.email = user
    }
    
    public func getUser() -> String {
        return LoggedInUser.email
    }
        

}
