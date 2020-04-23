//
//  LostItemAnnotation.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 23/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import Foundation

import MapKit

class LostItemAnnotation: MKPointAnnotation {
    var id: String
    var itemName: String
    var isFound: Bool
    var ownerID: String
    
    init(coordinate: CLLocationCoordinate2D, id: String, itemName: String, isFound: Bool, ownerID: String) {
        self.id = id
        self.itemName = itemName
        self.isFound = isFound
        self.ownerID = ownerID
        super.init()
        self.coordinate = coordinate
    }
}
