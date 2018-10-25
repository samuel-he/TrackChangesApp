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
    var tapToTheTop: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add gesture recognizer to move to the top on click
        tapToTheTop = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
        profileTitleLabel.addGestureRecognizer(tapToTheTop)
        
        tableView.estimatedRowHeight = 365
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /*****
     **** Tap to reload to top of the screen
     *****/
    @objc func scrollToTop() {
        tableView.setContentOffset(.zero, animated: true)
    }
    
    @IBAction func viewFollowing(_ sender: Any) {
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
            return UITableViewAutomaticDimension
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
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            return cell
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
