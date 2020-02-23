//
//  NewMessageController.swift
//  ChatApplication
//
//  Created by Yash on 6/8/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class NewMessageController: UITableViewController, CLLocationManagerDelegate {
    var messagesController: MessagesController?
    
    let cellId = "cellId"
    var appUsers = [AppUser]()
    var userDistances = [String]()
    var range=1000 {
        didSet {
            self.title = "\(range)km"
        }
    }
    
    let locationManager: CLLocationManager = CLLocationManager()
        override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(handleChangeRange))
        tableView.register(AppUserCell.self, forCellReuseIdentifier: cellId)
        range = 100
        configureLocationManager()
     }
    
    @objc func handleChangeRange() {
        //Gets the value from the sliders and sets the range filter
        let rangeSelectorViewController = RangeSelectorViewController()
        rangeSelectorViewController.newMessageController = self
        let navController = UINavigationController(rootViewController: rangeSelectorViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fetchUser(userLocation: locations[locations.count-1])
        locationManager.stopUpdatingLocation()
    }
    
    func fetchUser(userLocation: CLLocation)
    {
        appUsers.removeAll()
        userDistances.removeAll()
        let rootRef = Database.database().reference()
        let geoRef = GeoFire(firebaseRef: rootRef.child("user_locations"))
        
        let query = geoRef.query(at: userLocation, withRadius: Double(range))
        
        query.observe(.keyEntered, with: { key, location in
            Database.database().reference().child("users").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    if snapshot.key != Auth.auth().currentUser?.uid {
                        let appUser = AppUser()
                        //Initialise the properties of the appUser object with the values retrieved from Firebase
                        appUser.uid = snapshot.key
                        appUser.name = dictionary["name"] as? String
                        appUser.email = dictionary["email"] as? String
                        appUser.profileImageURL = dictionary["profileImageURL"] as? String
                        //Add the appUser to the appUsers array and populate the table view with the retrieved users
                        self.appUsers.append(appUser)
                        let distanceFromUser = location.distance(from: userLocation) / 1000
                        self.userDistances.append(String(format: "%.01f km away", distanceFromUser))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }, withCancel: nil)
        })   
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Populates the table view with the users in the appUsers array
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AppUserCell
        
        let appUser = appUsers[indexPath.row]
        cell.textLabel?.text = appUser.name
        cell.detailTextLabel?.text = appUser.email
        cell.timeLabel.text = userDistances[indexPath.row]
        
        if let profileImageURL = appUser.profileImageURL{
            cell.profileImageView.loadImageFromCache(withURLString: profileImageURL)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dissmiss completed")
            let appUser = self.appUsers[indexPath.row]
            self.messagesController?.showChatController(forAppUser: appUser)
        }
    }
    
}
