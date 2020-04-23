//
//  LoginViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //hides error label
        error.alpha = 0
        
        Styles.styleTextField(email)
        Styles.styleTextField(password)
        Styles.styleFilledButton(login)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        let errorMessage = checkBlankFields()
        
        if errorMessage == nil {
            
            // Signing in the user
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (result, error) in
                
                if error == nil {
                    
                    print("Successfully logged in")
                    
                    // Store logged in user in a Singleton object to be accessed by every view controller
                    LoggedInUser(user: self.email.text!)
                    
                    // Transition to Homepage
                    self.performSegue(withIdentifier: "toHome", sender: self)
                    
                }
                else {
                    self.showError("Login credentials are incorrect!")
                    
                }
            }
            
            
        } else {
            self.showError(errorMessage!)
        }
    }
    
    // Check if all user input fields are filled.
    // If everything is correct, this method returns nil.
    // Otherwise, it returns the error message
    func checkBlankFields() -> String? {
        
        // Check that all fields are filled in
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""  {
            
            return "Please fill in all fields."
        }
        
        if email.text == "Email" {
            return "Please enter your email."
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
            let tabBarController = segue.destination as? TabBarController {
            
            tabBarController.loggedInUser = self.email.text!
            
        }
//            let newVC = segue.destination as? HomeTableViewController
//             {
//                // Passes information about logged in user to the homepage
//                newVC.loggedInUser = self.email.text!
//                print("Info updated")
//            }
    }
    


}
