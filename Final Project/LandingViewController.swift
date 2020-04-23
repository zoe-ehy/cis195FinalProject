//
//  LandingViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LandingViewController: UIViewController {
    var ref: DatabaseReference!

    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Styles.styleFilledButton(login)
        Styles.styleFilledButton(signUp)

        ref = Database.database().reference()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
    }
    


}
