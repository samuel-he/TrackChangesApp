//
//  FollowViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/14/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

var SelectedUser = User()

class FollowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
//    var tapToTheTop: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        tapToTheTop = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
//        titleLabel.addGestureRecognizer(tapToTheTop)
    }
    
    /****
    *** Scroll to the top on title click
    ****/
    @objc func scrollToTop() {
        tableView.setContentOffset(.zero, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ViewFollowers {
            title = "Followers"
        } else {
            title = "Following"
        }
    }
    
    // Go back to profile page
    @IBAction func backToProfile(_ sender: Any) {
        ViewFollowers = false
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FollowFromProfile {
            if ViewFollowers {
                return currentUser.followers.count
            } else {
                return currentUser.following.count
            }
        } else {
            if ViewFollowers {
                return SelectedUser.followers.count
            } else {
                return SelectedUser.following.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if FollowFromProfile {
            if ViewFollowers {
                SelectedUser = currentUser.followers[indexPath.row]
            } else {
                SelectedUser = currentUser.following[indexPath.row]
            }
        } else {
        
            if ViewFollowers {
                SelectedUser = SelectedUser.followers[indexPath.row]
            } else {
                SelectedUser = SelectedUser.following[indexPath.row]
            }
        }

        self.performSegue(withIdentifier: "FollowToProfile", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
        
        if ViewFollowers  {
            cell.name.text = currentUser.followers[indexPath.row].displayName
            cell.username.text = currentUser.followers[indexPath.row].username
            do {
                let data = try Data(contentsOf: URL(string: currentUser.followers[indexPath.row].imageUrl)!)
                cell.profilePic.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            cell.name.text = currentUser.following[indexPath.row].displayName
            cell.username.text = currentUser.following[indexPath.row].username
            do {
                let data = try Data(contentsOf: URL(string: currentUser.following[indexPath.row].imageUrl)!)
                    cell.profilePic.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }

        return cell 
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
