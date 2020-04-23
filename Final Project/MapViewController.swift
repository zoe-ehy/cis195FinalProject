//
//  MapViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Kingfisher

class MapViewController: UIViewController {
    
    @IBOutlet private var mapView: MKMapView!
    let db = Firestore.firestore()
    
    var itemGeopoints = [LostItemAnnotation]()

    override func viewDidLoad() {
        print("-----MAP-----")
        super.viewDidLoad()
        mapView.delegate = self
        retrieveDataFromFirestoreAndSetUpAnnotations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerMapOnPennCampus()
    }

    private func centerMapOnPennCampus() {
        
        let coord = CLLocationCoordinate2D(latitude: 39.951389, longitude: -75.193775)
        let regionRadius: CLLocationDistance = 2000
        
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.setRegion(region,animated: true)
    }
    
    // Only displays items which are still lost
    // Only owners of the item can click "Found It!" in the pop-up
    private func retrieveDataFromFirestoreAndSetUpAnnotations() {
        
        // Clears existing elements before refresh and reload new elements
        self.itemGeopoints.removeAll()
        
        db.collection("items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    
                if let docId = document.documentID as? String,
                    let name = document.get("itemName") as? String,
                    let ownerID = document.get("ownerID") as? String,
                    let loc = document.get("location") as? String,
                    let isFound = document.get("isFound") as? Bool,
                    let lat = document.get("lat") as? String,
                    let lon = document.get("lon") as? String {
                    
                        print(docId, name, ownerID, isFound, loc, lat, lon)
                            let latDouble = Double(lat)!
                            let lonDouble = Double(lon)!
                    
                         // Only display if the item is still lost
                         if !isFound {
                             let coord = CLLocationCoordinate2D(latitude: latDouble, longitude: lonDouble)
                             let item = LostItemAnnotation(coordinate: coord, id: docId, itemName: name, isFound: isFound, ownerID: ownerID)
                             
                             self.itemGeopoints.append(item)
                             
                             // Add annotations to map
                             self.mapView.addAnnotations(self.itemGeopoints)

                             }
                    }
                }
            }
        }
        }
    }
    


// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

    // Called everytime a new annotation is added
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let identifier = "LostItemAnnotationIdentifier"
        guard let lostItemAnnotation = annotation as? LostItemAnnotation else { return nil }

        // DONE: Create the annotation
        // - Try to dequeue an Annotation view with the identifier
        //   - If successful, just update the annotation
        //   - If unsuccessful, make a new MKAnnotationView
        var annotationView: MKAnnotationView?

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView = dequeuedView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }

        // Customize LostItemAnnotation
        // - Configure the callout view
        // - Customize the .image, add a custom label & button
        if let annotationView = annotationView {
            annotationView.canShowCallout = true    //makes annotation tapable
            
            // Resize custom pin image
            let size = CGSize(width: 44, height: 44)
            UIGraphicsBeginImageContext(size)
            UIImage(named: "pin")?.draw(in: CGRect(origin: .zero, size: size))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView.image = resizedImage
            
            annotationView.detailCalloutAccessoryView = getCalloutLabel(with: lostItemAnnotation.itemName)
            annotationView.rightCalloutAccessoryView = getCalloutButton (isFound: lostItemAnnotation.isFound)
        
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        if let button = view.rightCalloutAccessoryView as? UIButton {
            if let lostItemAnnotation = view.annotation as? LostItemAnnotation {

                // DONE:
                // - Toggle state of the egg annotation
                // - Update the button with the correct title
                // - Update the firebase database with the new `isCollected` value
                lostItemAnnotation.isFound.toggle()

                view.rightCalloutAccessoryView = getCalloutButton (isFound: lostItemAnnotation.isFound)

                // Save changes to database
                db.collection("items").document(lostItemAnnotation.id).setData([ "isFound": true ], merge: true)

            }
        }
    }

    // Configures itemName label
    private func getCalloutLabel(with name: String) -> UILabel {
        let label = UILabel()
        label.text = name
        return label
    }

    // Configures button
    private func getCalloutButton(isFound: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(isFound ? "Awesome!" : "Found it?", for: .normal)
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.tintColor = .white
        button.frame = CGRect.init(x: 0, y: 0, width: 100, height: 40)
        return button
    }
}
