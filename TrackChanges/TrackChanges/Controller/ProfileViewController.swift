//
//  ProfileViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/14/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

// Variable that determines the title of the FollowViewController 
var ViewFollowers = Bool()

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func viewFollowing(_ sender: Any) {
        ViewFollowers = false
        self.performSegue(withIdentifier: "goToFollow", sender: nil)
    }
    
    @IBAction func viewFollowers(_ sender: Any) {
        ViewFollowers = true 
        self.performSegue(withIdentifier: "goToFollow", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 245
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
            
            cell.profilePic.image = currentUser.image
            cell.name.text = currentUser.displayName
            cell.username.text = "@" + currentUser.username
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            return cell
        }
    }

}
