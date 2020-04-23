//
//  TabBarController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 23/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    var loggedInUser: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewControllers = viewControllers else {
            return
        }
        
        // Passes information from VC before tab bar controller
        for viewController in viewControllers {
            if let home = viewController as? HomeTableViewController {
                home.loggedInUser = self.loggedInUser
                print("Info passed to Home!")
            }
            if let myLostItems = viewController as? MyLostItemsTableViewController {
                myLostItems.loggedInUser = self.loggedInUser
                print("Info passed to myLostItems!")
            }
            
            
        }
    }
    
    
}


