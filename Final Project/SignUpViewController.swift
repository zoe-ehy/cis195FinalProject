//
//  SignUpViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reenterPassword: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        error.alpha = 0
        Styles.styleTextField(firstName)
        Styles.styleTextField(lastName)
        Styles.styleTextField(email)
        Styles.styleTextField(password)
        Styles.styleTextField(reenterPassword)
        Styles.styleFilledButton(signUp)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let errorMessage = checkBlankFieldsAndPasswordMatch()
        
        if errorMessage == nil {
            
            // carry out Firebase Authentication
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (result, err) in
                if err == nil {
                    
                    // Create & store user in Firebase Database
                    
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("users").addDocument(data: [
                        "firstName": self.firstName.text!,
                        "lastName": self.lastName.text!,
                        "email": self.email.text!,
                        "uid": result!.user.uid
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                        }
                    }
                    
                    // Transition to the home screen
                    
                    self.performSegue(withIdentifier: "toHome", sender: self)
                    
                } else {
                    
                    // Display error message
                    self.showError(err!.localizedDescription)
                }
            }
            
            
        } else {
            //if any of the input fields are blank or the passwords don't match
            self.showError(errorMessage!);
            
        }
    
    }
    // Check if all user input fields are filled.
    // Checks both password fields match.
    // If everything is correct, this method returns nil.
    // Otherwise, it returns the error message
    func checkBlankFieldsAndPasswordMatch() -> String? {
        
        // Check that all fields are filled in
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            reenterPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            firstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  ||
            lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please fill in all fields."
        }
        
        
        if firstName.text == "First name" {
            return "Please enter your first name."
        }
        
        if lastName.text == "Last name" {
            return "Please enter your last name."
        }
        

        // Verifies password
        if (password.text != reenterPassword.text) {
            return "Passwords need to match."
        }
        
        return nil
    }
    
    // Display error message
    func showError(_ message:String) {
        error.text = message
        error.alpha = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare called")

        if segue.identifier == "toHome",
            let newVC = segue.destination as? HomeTableViewController
             {
                // Passes information about logged in user to the homepage
                newVC.loggedInUser = self.email.text!
                print("Info updated")
            }
    }


}
