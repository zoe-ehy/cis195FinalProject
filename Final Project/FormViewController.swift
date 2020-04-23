//
//  FormViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import CoreLocation
import MapKit

class FormViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var loggedInUserID = ""
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var loc: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var share: UIButton!
    
    var imageURL: String = ""
    var lat: String = ""
    var lon: String = ""
    
    
    override func viewDidLoad() {
        print("-----FORM VIEW FOR NEW LOST ITEM-----")
        super.viewDidLoad()
        print("LOGGED IN USER: " + LoggedInUser.email)
        
        Styles.styleTextField(itemName)
        Styles.styleTextField(desc)
        Styles.styleTextField(date)
        Styles.styleTextField(loc)
        Styles.styleTextField(address)
        Styles.styleTextField(contact)
        Styles.styleFilledButton(share)
        
        // convert email of logged in user to userID
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let docId = document.documentID
                    
                    let email = document.get("email") as! String
                    
                    // retreive items of logged in user
                    if (email == LoggedInUser.email) {
                        self.loggedInUserID = docId
                    }
                }
            }
        }

    }
    
    // Presents image picker when user taps on image
    @IBAction func presentImagePicker(_ gesture: UIGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // Method that fits selectedImage to UIImage after user picks an image from camera roll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            itemImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        uploadPhotoToFirebase()
    }
    
    private func uploadPhotoToFirebase() {
        print("Starting upload to Firebase Storage...")
         
        guard let image = itemImage.image,
            let imageData = image.jpegData(compressionQuality: 1.0) else {
                showError("Unable to covert UIImage to JPEG.")
                return
        }
        
        // Generates a random UUID for imageName
        let imageName = UUID().uuidString + ".jpeg"
        
        // Create a root reference
        let storageRef = storage.reference()

        // Create a reference to image
        let imageRef = storageRef.child(imageName)
        
        imageRef.putData(imageData, metadata: nil) { (metadata, err) in
            if let err = err {
                self.showError("Unable to upload image to Firebase Storage. " + err.localizedDescription)
                return
            }
            
            // Retrieve URL from storage
            imageRef.downloadURL { (url, error) in
                
                // Error handling
                if let err = err {
                    self.showError("Unable to download image URL from Firebase Storage. " + err.localizedDescription)
                    return
                }
                
                // Error handling
                  guard let downloadURL = url else {
                    self.showError("Unable to download image URL from Firebase Storage. ")
                    return
                  }
                
                // Convert URL to String and stored
                let urlString = downloadURL.absoluteString
                self.imageURL = urlString
                
            }
        }
        
        print("Upload successful!")
        let alert = UIAlertController(title: "Upload successful!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
    let errorMessage = checkFields()
    
        if errorMessage == nil {

            // Add new Lost Item to "items" database
            var itemRef: DocumentReference? = nil
            itemRef = self.db.collection("items").addDocument(data: [
                "ownerID": self.loggedInUserID,
                "itemName": self.itemName.text!,
                "description": self.desc.text!,
                "date": self.date.text!,
                "location": self.loc.text!,
                "isFound": false,
                "imageURL": self.imageURL,
                "contact": self.contact.text!,
                "lat": self.lat,
                "lon": self.lon
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(itemRef!.documentID)")
                }
            }
            
            // Update myItems in "users" database by appending new item to the value array
            let userRef = db.collection("users").document(self.loggedInUserID)

            userRef.updateData([
                "items": FieldValue.arrayUnion([itemRef!.documentID])
            ])
            
            // Segue back to Home
            navigationController?.popViewController(animated: true)
            
        } else {
            self.showError(errorMessage!)
        }
    }
    
    private func convertAddressToLatLon(address: String) {
        print("Tring to convert...")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                self.showError(error!.localizedDescription)
            }
            
            // Location successfully generated
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                print("Lat: \(coordinates.latitude) -- Long: \(coordinates.longitude)")
                
                self.lat = String(coordinates.latitude)
                self.lon = String(coordinates.longitude)
                
                print(self.lat)
                print(self.lon)

                let position = CLLocationCoordinate2DMake(coordinates.latitude,coordinates.longitude)

            } else {
                self.showError("Unable to generate location, please specify your coordinates.")
            }
        })
        
    }
    
    // Check if all user input fields are filled.
    // If everything is correct, this method returns nil.
    // Otherwise, it returns the error message
    private func checkFields() -> String? {
        
        convertAddressToLatLon(address: self.address.text!)
        
        // Check that all fields are filled in
        if itemName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        desc.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        date.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        loc.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        contact.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        if itemName.text == "What is it?" {
            return "Please enter the name of your lost item."
        }
        
        if desc.text == "How does it look like?" {
            return "Please enter the description of your lost item."
        }
        
        if date.text == "When did you lose it?" {
            return "Please enter the date of when you last saw your item."
        }
        
        if loc.text == "Where did you lose it?" {
            return "Please enter the location of where you last saw your item."
        }
        
        if contact.text == "How do we contact you if found?" {
            return "Please enter your means of contact so people can reach you if your item is found."
        }
        
        if imageURL == "" {
            return "Please choose and image of your lost item to upload."
        }
        
        return nil
    }
    
    // Display error message
    private func showError(_ errorMessage:String) {
         let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)

                           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                           
                           self.present(alert, animated: true)
    }

}
