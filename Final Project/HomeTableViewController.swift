//
//  HomeTableViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class HomeTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    
    var items = [lostItem]()
    var loggedInUser: String = ""

    @IBOutlet weak var addNewLostItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        print("-----HOME NEWS FEED-----")
        super.viewDidLoad()
        configureRefreshControl()
        self.tableView.refreshControl?.beginRefreshing()
        retrieveDataFromFirestore()
        print("LOGGED IN USER: " + loggedInUser)
        print("Singleton: " + LoggedInUser.email)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("-----HOME NEWS FEED-----")
        self.tableView.refreshControl?.beginRefreshing()
        retrieveDataFromFirestore()
        print("LOGGED IN USER: " + loggedInUser)
    }
    
    func configureRefreshControl () {
       // Add the refresh control to your UIScrollView object.
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
    }
        
    @objc func handleRefreshControl() {
       // Update your content…
        retrieveDataFromFirestore()
    }
    
    private func retrieveDataFromFirestore() {
        
        // Clears existing elements before refresh and reload new elements
        self.items.removeAll()
        
        db.collection("items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    let docId = document.documentID
                    let name = document.get("itemName") as! String
                    let ownerID = document.get("ownerID") as! String
                    let desc = document.get("description") as! String
                    let date = document.get("date") as! String
                    let loc = document.get("location") as! String
                    let contact = document.get("contact") as! String
                    let imageStr = document.get("imageURL") as! String
                    let isFound = document.get("isFound") as! Bool
                   print(docId, name, ownerID, desc, loc)
                    
                    let imageURL = URL(string: imageStr)
                    
                    // Only display if the item is still lost
                    if !isFound {
                        //converts owner ID to user's fullname by querying the database again
                        let userRef = self.db.collection("users").document(ownerID)

                        userRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                
                                let first = document.get("firstName") as! String
                                let last = document.get("lastName") as! String
                                let fullname = first + " " + last
                                
                                let item = lostItem(docID: docId, owner: fullname, itemName: name, description: desc, date: date, location: loc, contact: contact, image: imageURL!, isFound: isFound)
                                
                                self.items.append(item)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.tableView.refreshControl?.endRefreshing()
                                }
                            } else {
                                print("User document does not exist")
                            }
                        }
                    }

                }
                self.tableView.refreshControl?.endRefreshing()
                DispatchQueue.main.async {
                    if (self.items.count == 0) {
                        let alert = UIAlertController(title: "No one lost anything!", message: "", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                    }
                }
                
            }
        }
    }

    // MARK: - Table view data source

    @IBAction func addNewLostItem(_ sender: Any) {
        print("Add button")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 640.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(self.items.count)
        print(indexPath.row)
        let itemPost = items[indexPath.row]
        
        dump(itemPost)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemPostCell")!
        
        if let owner = cell.viewWithTag(1) as? UILabel {
            owner.text = itemPost.owner
            owner.textColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        }
        
        if let name = cell.viewWithTag(2) as? UILabel {
            name.text = itemPost.itemName
        }
        
        if let image = cell.viewWithTag(3) as? UIImageView {
            image.kf.setImage(with: itemPost.image)
        }
        
        if let desc = cell.viewWithTag(4) as? UITextView {
            desc.text = itemPost.description
        }
        
        if let date = cell.viewWithTag(5) as? UILabel {
            date.text = itemPost.date
        }
        
        if let location = cell.viewWithTag(6) as? UILabel {
            location.text = itemPost.location
        }
        
        if let contact = cell.viewWithTag(7) as? UILabel {
            contact.text = itemPost.contact
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
