//
//  FollowingProfileViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream

var globalState: Bool?

class PeopleProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {

    @IBOutlet weak var tableView: UITableView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup a socket to backend
//        var request = URLRequest(url: URL(string: "ws://172.20.10.6:8080/TrackChangesBackend/endpoint")!)
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
        socket.delegate = self
//        socket.connect()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        socket.delegate = self
        
        getFollowers()
        getFollowings()
        getPosts()
        getFollowingState()
    }
    
    @IBAction func viewFollowing(_ sender: Any) {
        FollowFromProfile = false
        ViewFollowers = false
        self.performSegue(withIdentifier: "PeopleProfileToFollow", sender: nil)
    }
    
    /****
     *** View Followers
     ****/
    
    @IBAction func viewFollowers(_ sender: Any) {
        FollowFromProfile = false 
        ViewFollowers = true
        self.performSegue(withIdentifier: "PeopleProfileToFollow", sender: nil)
    }
    
    
    
    /****
    *** Follow the user of the page
    ****/
    
    @IBAction func followUser(_ sender: Any) {
        let sender = sender as! UIButton
        
        if sender.title(for: .normal) == "Follow" {
            let json:NSMutableDictionary = NSMutableDictionary()
            
            json.setValue("follow", forKey: "request")
            json.setValue(SelectedUser?.username, forKey: "user_id")
            json.setValue(currentUser.username, forKey: "follower_id")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            print(jsonString)
            
            socket.write(data: jsonData)
            
            sender.setTitle("Following", for: .normal)
        } else {
            let json:NSMutableDictionary = NSMutableDictionary()
            
            json.setValue("unfollow", forKey: "request")
            json.setValue(SelectedUser?.username, forKey: "user_id")
            json.setValue(currentUser.username, forKey: "follower_id")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            print(jsonString)
            
            socket.write(data: jsonData)
            
            sender.setTitle("Follow", for: .normal)
        }
        
        getFollowers()
        getFollowings()
        getFollowingState()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 280
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return SelectedUser?.posts.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
            
            do {
                let data = try Data(contentsOf: URL(string: (SelectedUser?.imageUrl)!)!)
                cell.profilePic.layer.borderWidth = 1
                cell.profilePic.layer.masksToBounds = false
                cell.profilePic.layer.borderColor = UIColor.black.cgColor
                cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height/2
                cell.profilePic.clipsToBounds = true
                cell.profilePic.image = currentUser.image
                cell.profilePic.image = UIImage.init(data: data)
                
            } catch {
                print(error.localizedDescription)
            }
            cell.name.text = SelectedUser?.displayName
            cell.username.text = "@" + (SelectedUser?.username)!
            
            if globalState == true {
                cell.followButton.setTitle("Following", for: .normal)
            } else {
                cell.followButton.setTitle("Follow", for: .normal)
            }
            
            if let count = SelectedUser?.followers?.count {
                cell.followersCount.setTitle("\(count)", for: .normal)
            }
            
            if let count = SelectedUser?.following?.count {
                cell.followingCount.setTitle("\(count)", for: .normal)
            }
    
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            return cell
            
            cell.postContent.text = SelectedUser?.posts[indexPath.row].message
            cell.name.text = SelectedUser?.displayName
            
            do {
                let data = try Data(contentsOf: URL(string: (SelectedUser?.imageUrl)!)!)
                cell.profilePic.layer.borderWidth = 1
                cell.profilePic.layer.masksToBounds = false
                cell.profilePic.layer.borderColor = UIColor.black.cgColor
                cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height/2
                cell.profilePic.clipsToBounds = true
                cell.profilePic.image = currentUser.image
                cell.profilePic.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            cell.username.text = SelectedUser?.username
            
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            print(jsonString)
            
            // User followers response
            if json["response"] as? String == "followers" {
                let followers = json["followers"] as! [[String: Any]]
                for user in followers {
                    var follower = User()
                    follower.imageUrl = user["user_imageurl"] as! String
                    follower.username = user["user_id"] as! String
                    follower.displayName = user["user_displayname"] as! String
                    
                    print(follower.displayName)
                    
                    SelectedUser?.followers?.append(follower)
                }
            }
            
            // User following response
            if json["response"] as? String == "followings" {
                let following = json["followings"] as! [[String: Any]]
                for user in following {
                    var following = User()
                    following.imageUrl = user["user_imageurl"] as! String
                    following.username = user["user_id"] as! String
                    following.displayName = user["user_displayname"] as! String
                    
                    print(following.displayName)
                    
                    SelectedUser?.following?.append(following)
                }
            }
            
            // User post response
            if json["response"] as? String == "feed" {
                let posts = json["feed"] as! [[String: Any]]
            }
            
            // User following state
            // {"response":"is_following","is_following":true}
            if json["response"] as? String == "is_following" {
                let state = json["is_following"] as? Bool
                print(state!)
                globalState = state
                
            }
            
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /***
     ** Get current users followers
     ***/
    
    func getFollowers() {
        SelectedUser?.followers?.removeAll()
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_followers", forKey: "request")
        json.setValue(SelectedUser?.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    /***
     ** Get current users following
     ***/
    
    func getFollowings() {
        SelectedUser?.following?.removeAll()
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_followings", forKey: "request")
        json.setValue(SelectedUser?.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    /***
     ** Get current users posts
     ***/
    
    func getPosts() {
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_posts", forKey: "request")
        json.setValue(SelectedUser?.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    func getFollowingState() {
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("is_following", forKey: "request")
        
        json.setValue(SelectedUser?.username, forKey: "user_id")
        json.setValue(currentUser.username, forKey: "follower_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
}
