//
//  lostItem.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import Foundation

class lostItem {
    var docID: String
    var owner: String
    var itemName: String
    var description: String
    var date: String
    var location: String
    var isFound: Bool
    var contact: String
    var image: URL
    
    init(docID: String, owner: String, itemName: String, description: String, date: String, location: String, contact: String, image: URL, isFound: Bool) {
        self.docID = docID
        self.owner = owner
        self.itemName = itemName
        self.description = description
        self.date = date
        self.location = location
        self.isFound = isFound
        self.contact = contact
        self.image = image
        
    }
    
    public func found() {
        self.isFound = true
    }
}

