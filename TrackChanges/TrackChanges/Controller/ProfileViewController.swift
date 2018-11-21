//
//  ProfileViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/14/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream

// Variable that determines the title of the FollowViewController 
var ViewFollowers = Bool()

var FollowFromProfile = Bool()

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.delegate = self
        
//        getFollowers()
//        getFollowings()
//        getPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFollowers()
        getFollowings()
        getPosts()
    }
    
    // MARK: WebSocket connection and handling
    
    /***
    ** Get current users followers
    ***/
    
    func getFollowers() {
        currentUser.followers?.removeAll()
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_followers", forKey: "request")
        json.setValue(currentUser.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    /***
    ** Get current users following
    ***/
    
    func getFollowings() {
        currentUser.following?.removeAll()
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_followings", forKey: "request")
        json.setValue(currentUser.username, forKey: "user_id")
        
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
        json.setValue(currentUser.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
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
            
            // User followers response
            if json["response"] as? String == "followers" {
                let followers = json["followers"] as! [[String: Any]]
     
                for user in followers {
                    var follower = User()
                    follower.imageUrl = user["user_imageurl"] as! String
                    follower.username = user["user_id"] as! String
                    follower.displayName = user["user_displayname"] as! String
                    
                    currentUser.followers?.append(follower)
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
                    
                    currentUser.following?.append(following)
                }
            }
            // User post response
            if json["response"] as? String == "feed" {
                let posts = json["feed"] as! [[String: Any]]
                for post in posts {
                    if post["song_id"] as? String == "" {
                        print("asdkhjasldkajsdlkasjdalk")
                    }
                    
                }
            }
            
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func viewFollowing(_ sender: Any) {
        FollowFromProfile = true 
        ViewFollowers = false
        self.performSegue(withIdentifier: "goToFollow", sender: nil)
    }
    
    @IBAction func viewFollowers(_ sender: Any) {
        FollowFromProfile = true
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return currentUser.posts.count
        }
    }
    
    func makeRequest(url: String, id: String) {
        // Request accecssToken
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        let tokenUrl = "https://accounts.spotify.com/api/token"
        
        // Request access token to make search requests
        var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
        tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        tokenRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let accessToken = (json["access_token"] as? String)!
                        
                        // Make request 
                        var requestUrl = url
                        requestUrl += id
                        
                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if let data = data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }.resume()
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
            
            cell.profilePic.layer.borderWidth = 1
            cell.profilePic.layer.masksToBounds = false
            cell.profilePic.layer.borderColor = UIColor.black.cgColor
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.height/2
            cell.profilePic.clipsToBounds = true
            cell.profilePic.image = currentUser.image
            
            cell.name.text = currentUser.displayName
            cell.username.text = "@" + currentUser.username
            cell.followersCount.setTitle("\(currentUser.followers?.count ?? 0)", for: .normal)
            cell.followingCount.setTitle("\(currentUser.following?.count ?? 0)", for: .normal)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            
            cell.postContent.text = currentUser.posts[indexPath.row].message
            cell.name.text = currentUser.displayName
            cell.username.text = currentUser.username
            
            
            cell.profilePic.image = currentUser.image

            
            if currentUser.posts[indexPath.row].albumId == "" && currentUser.posts[indexPath.row].trackId == "" {
                cell.shareContent.isHidden = true
            } else {
                cell.shareContent.isHidden = false
                
                if currentUser.posts[indexPath.row].albumId == "" {
                    // Make request to Spotify for track info
                    // Request accecssToken
                    let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
                    let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
                    
                    let tokenUrl = "https://accounts.spotify.com/api/token"
                    
                    // Request access token to make search requests
                    var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
                    tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
                    tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
                    tokenRequest.httpMethod = "POST"
                    
                    URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    let accessToken = (json["access_token"] as? String)!
                                    
                                    // Make request
                                    var requestUrl = "https://api.spotify.com/v1/tracks/"
                                    requestUrl += currentUser.posts[indexPath.row].trackId!
                                    
                                    var request = URLRequest(url: URL.init(string: requestUrl)!)
                                    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                    
                                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                                        if let data = data {
                                            do {
                                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                    
                                                }
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }.resume()
                                    
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        }.resume()

                } else {
                    // Make request to Spotify for album info
                    makeRequest(url: "https://api.spotify.com/v1/albums/", id: currentUser.posts[indexPath.row].albumId!)
                }
            }
            
            return cell
        }
    }

}
