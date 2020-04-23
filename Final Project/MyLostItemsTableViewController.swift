//
//  MyLostItemsTableViewController.swift
//  Final Project
//
//  Created by Zoe Er Hooi Yee on 22/4/20.
//  Copyright © 2020 Zoe Er Hooi Yee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MyLostItemsTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    
    var myItems = [lostItem]()
    var loggedInUser: String = ""
    
    
    override func viewDidLoad() {
        print("-----MY LOST ITEMS-----")
        super.viewDidLoad()
        configureRefreshControl()
        self.tableView.refreshControl?.beginRefreshing()
        self.retrieveDataFromFirestore()
        print("LOGGED IN USER: " + loggedInUser)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("-----MY LOST ITEMS-----")
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
        self.myItems.removeAll()
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let docId = document.documentID
                    
                    let email = document.get("email") as! String
                    
                    // retreive items of logged in user
                    if (email == self.loggedInUser) {
                        
                        print("User is: " + self.loggedInUser)
                        
                        if document.get("items") != nil {
                            let items = document.get("items") as! NSArray
                            
                            print("items exist")
                            
                            for item in items {
    
                                let itemID = (item as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                print("ID: " + itemID)
                                let itemRef = self.db.collection("items").document(itemID)

                                    itemRef.getDocument { (document, error) in
                                        if let error = error {
                                            print("Error getting item documents: \(error)")
                                        }
                                        if let document = document, document.exists {
                                           

                                            let docId = document.documentID
                                             let name = document.get("itemName") as! String
                                             let ownerID = document.get("ownerID") as! String
                                             let desc = document.get("description") as! String
                                             let date = document.get("date") as! String
                                             let loc = document.get("location") as! String
                                             let contact = document.get("contact") as! String
                                             let imageStr = document.get("imageURL") as! String
                                            let isFound = document.get("isFound")as! Bool
                                        

                                            let imageURL = URL(string: imageStr)

                                            let itemObject = lostItem(docID: docId, owner: ownerID, itemName: name, description: desc, date: date, location: loc, contact: contact, image: imageURL!, isFound: isFound)
                                            
                                            self.myItems.append(itemObject)

                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                                self.tableView.refreshControl?.endRefreshing()
                                            }
                                        }
                                    }
                            }
                        } else {
                            
                            let alert = UIAlertController(title: "", message: "You have no lost items!", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            self.present(alert, animated: true)
                            
                        }
                    }
                }
            }
        }
    }
    
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    // Item is considered found
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("Cell tapped")
        
        let cell = tableView.cellForRow(at: indexPath)
        let myItem = myItems[indexPath.row]
        
        myItem.found()
        db.collection("items").document(myItem.docID).setData([ "isFound": true ], merge: true)
        
        if let imageView = cell!.viewWithTag(4) as? UIImageView {
            imageView.image = UIImage(systemName: "circle.fill")
            imageView.tintColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        }
        
        self.tableView.reloadData()
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myItem = myItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myItemCell")!
        
        if let name = cell.viewWithTag(1) as? UILabel {
            name.text = myItem.itemName
        }
        
        if let date = cell.viewWithTag(2) as? UILabel {
            date.text = myItem.date
        }
        
        if let image = cell.viewWithTag(3) as? UIImageView {
            image.kf.setImage(with: myItem.image)
        }
        
        if let imageView = cell.viewWithTag(4) as? UIImageView {
            if myItem.isFound {
                imageView.image = UIImage(systemName: "circle.fill")
                imageView.tintColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
            } else {
                imageView.image = UIImage(systemName: "circle")
                imageView.tintColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
                
            }
            
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
