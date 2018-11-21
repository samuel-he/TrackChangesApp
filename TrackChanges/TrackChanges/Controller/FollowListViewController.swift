//
//  FollowListViewController.swift
//  TrackChanges
//
//  Created by Pavly Habashy on 11/18/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream

class FollowListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ViewFollowers {
            title = "Followers"
        } else {
            title = "Following"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FollowFromProfile {
            if ViewFollowers {
                return currentUser.followers?.count ?? 0
            } else {
                return currentUser.following?.count ?? 0
            }
        } else {
            if ViewFollowers {
                return (SelectedUser?.followers?.count)!
            } else {
                return (SelectedUser?.following?.count)!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if FollowFromProfile {
            if ViewFollowers {
                SelectedUser = currentUser.followers?[indexPath.row]
            } else {
                SelectedUser = currentUser.following?[indexPath.row]
            }
        } else {
            
            if ViewFollowers {
                SelectedUser = SelectedUser?.followers?[indexPath.row]
            } else {
                SelectedUser = SelectedUser?.following?[indexPath.row]
            }
        }
        
        self.performSegue(withIdentifier: "FollowToProfile", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowTableViewCell
        
        if ViewFollowers  {
            cell.name.text = currentUser.followers?[indexPath.row].displayName
            cell.username.text = currentUser.followers?[indexPath.row].username
            do {
                let data = try Data(contentsOf: URL(string: (currentUser.followers?[indexPath.row].imageUrl)!)!)
                cell.profilePic.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            cell.name.text = currentUser.following?[indexPath.row].displayName
            cell.username.text = currentUser.following?[indexPath.row].username
            do {
                let data = try Data(contentsOf: URL(string: (currentUser.following?[indexPath.row].imageUrl)!)!)
                cell.profilePic.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return cell
    }

}
