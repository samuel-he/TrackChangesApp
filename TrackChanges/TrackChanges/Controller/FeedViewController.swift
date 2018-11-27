//
//  FeedViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/13/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream
import Alamofire

var currentUser = User()
var SelectedUser: User?
var UserFeed = Feed()

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebSocketDelegate, UITabBarControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIBarButtonItem!
//    @IBOutlet weak var newPostsButton: UIButton!
    
    // Mini player stuff
    var miniPlayer: MiniPlayerViewController?
    var currentSong: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        SelectedUser = User()
        
        // Setup a socket to backend
        var request = URLRequest(url: URL(string: "ws://172.20.10.5:8080/TrackChangesBackend/endpoint")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        
        // Will send a JSON to backend upson establishing a connection
        socket.connect()
        
        if !GuestUser {
            // Retreive user information
            Alamofire.request("https://api.spotify.com/v1/me", method: .get, parameters: ["type":"user"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer " + AppRemote.connectionParameters.accessToken!]).responseJSON { response in
                
                // Parse user information into a global 'currrentUser' object
                self.parseData(JSONData: response.data!)
                self.addUserToDatabase()
                
                self.getFeed()
            }
        } else {
            self.getGuestFeed()
            tabBarController?.viewControllers?.removeLast()
//            tabBarController?.viewControllers?.removeLast()
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
//        newPostsButton.layer.borderColor = UIColor.black.cgColor
//        newPostsButton.layer.borderWidth = 1
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if !GuestUser {
            getFeed()
        } else {
            getGuestFeed()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notification.Name.init(rawValue: "newPost"), object: nil) 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        socket.delegate = self
        socket.connect()
        
        if !GuestUser {
            getFeed()
        } else {
            getGuestFeed()
        }
        
    }
    
    @objc func reloadTableView() {
        getPosts()
        tableView.reloadData()
    }
    
    // Parse spotify JSON
    func parseData(JSONData: Data) {
        let json = try? JSONSerialization.jsonObject(with: JSONData, options: [])
        if let dictionary = json as? [String: Any] {
            if let displayName = dictionary["display_name"] as? String {
//                print(displayName)
                currentUser.displayName = displayName
            }
            
            if let username = dictionary["id"] as? String {
//                print(username)
                currentUser.username = username
            }
            
            if let images = dictionary["images"] as? NSObject {
                if let array = images as? [Any] {
                    if let array = array.first {
                        if let anotherArray = array as? [String: Any] {
                            if let url = anotherArray["url"] as? String {
//                                print(url)
                                currentUser.imageUrl = url
                                
                                let url = URL.init(string: url)!
                                do {
                                    let data = try Data(contentsOf: url)
                                    currentUser.image = UIImage.init(data: data)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Adds user to database
    func addUserToDatabase() {
        let json:NSMutableDictionary = NSMutableDictionary()

        json.setValue("add_user", forKey: "request")
        json.setValue(currentUser.username, forKey: "user_id")
        json.setValue(currentUser.displayName, forKey: "user_displayname")
        json.setValue(currentUser.imageUrl, forKey: "user_imageurl")
        
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
        
        json.setValue(String(time.description), forKey: "user_logintimestamp")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    func getFeed() {
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_feed", forKey: "request")
        json.setValue(currentUser.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
      
        socket.write(data: jsonData)
    }
    
    func getGuestFeed() {
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_guest_feed", forKey: "request")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !GuestUser {
           return UserFeed.posts.count
        } else {
            return 1
        }
        
    }
    
    @IBAction func playSongFromPost(_ sender: Any) {
        let sender = sender as! UIButton
        
        
        AppRemote.playerAPI?.play((UserFeed.posts[sender.tag].track.uri), callback: { (result, error) in
            print(error?.localizedDescription)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        if !GuestUser {
            // Add a tag to identify which cell was selected
            cell.playPauseButton.tag = indexPath.row
            cell.postContent.text = UserFeed.posts[indexPath.row].message
            cell.name.text = UserFeed.posts[indexPath.row].user.displayName
            cell.username.text = UserFeed.posts[indexPath.row].user.username
            
            do {
                let data = try Data(contentsOf: URL.init(string: UserFeed.posts[indexPath.row].user.imageUrl)!)
                cell.profilePic.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            if UserFeed.posts[indexPath.row].type == "regular" {
                cell.shareContent.isHidden = true
            } else {
                cell.shareContent.isHidden = false
                
                if UserFeed.posts[indexPath.row].type == "song" {
                    cell.playPauseButton.isHidden = false
                    
                    
                    cell.title.text = UserFeed.posts[indexPath.row].track.name
                    cell.artist.text = UserFeed.posts[indexPath.row].track.album.artist.name
                    
                    do {
                        let data = try Data(contentsOf: URL.init(string: UserFeed.posts[indexPath.row].track.album.image)!)
                        cell.coverImage.image = UIImage.init(data: data)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                } else {
                    cell.playPauseButton.isHidden = true
                    
                    cell.title.text = UserFeed.posts[indexPath.row].album.name
                    cell.artist.text = UserFeed.posts[indexPath.row].track.album.artist.name
                    
                    do {
                        let data = try Data(contentsOf: URL.init(string: UserFeed.posts[indexPath.row].track.album.image)!)
                        cell.coverImage.image = UIImage.init(data: data)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            cell.name.text = "TrackChanges"
            cell.username.text = "@TrackChanges"
            cell.profilePic.image = UIImage.init(named: "play")
            cell.postContent.text = "Connect with Spotify to view a Feed"
        }
        
        
        
        return cell
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
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
        print("Received dumbass text: \(text)")
    }
    
    func getPosts() {
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("get_posts", forKey: "request")
        json.setValue(currentUser.username, forKey: "user_id")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
    }
    
    @IBAction func updateFeed(_ sender: Any) {
//        newPostsButton.isHidden = true
        getPosts()
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print(json)
            
            // User followers response
            if json["response"] as? String == "post_added" {
                print("PLEASE")
                let postUser = User()
                postUser.displayName = json["post_user_displayname"] as! String
                postUser.username = json["post_user_id"] as! String
                postUser.username = "@" + postUser.username
                postUser.imageUrl = json["post_user_imageurl"] as! String
                
                var feedPost = Post()
                feedPost.albumId = json["post_album_id"] as! String
                feedPost.message = json["post_message"] as! String
                feedPost.timestamp = json["post_timestamp"] as! String
                feedPost.trackId = json["post_song_id"] as! String
                feedPost.type = json["post_type"] as! String
                feedPost.user = postUser
                
                UserFeed.addPost(post: feedPost)
                UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                for post in UserFeed.posts {
                    print(post.id)
                }
                
                print("")
                tableView.reloadData()
            }
            
            
            if json["response"] as? String == "guest_feed" {
                UserFeed.posts.removeAll()
                print(json)
                let feed = json["guest_feed"] as! [[String: Any]]
                
                // Create new post for each item and add to user's feed
                for item in feed {
                    // Get the user info who posted
                    let postUser = User()
                    postUser.displayName = item["post_user_displayname"] as! String
                    postUser.username = item["post_user_id"] as! String
                    postUser.username = "@" + postUser.username
                    postUser.imageUrl = item["post_user_imageurl"] as! String
                    
                    let feedPost = Post()
                    feedPost.albumId = item["post_album_id"] as! String
                    feedPost.message = item["post_message"] as! String
                    feedPost.timestamp = item["post_timestamp"] as! String
                    feedPost.trackId = item["post_song_id"] as! String
                    feedPost.type = item["post_type"] as! String
                    feedPost.id = item["post_id"] as! String
                    feedPost.user = postUser
                    
                    
                    if feedPost.type == "song" {
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
                                        requestUrl += feedPost.trackId!
                                        
                                        
                                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                        
                                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                                            if let data = data {
                                                do {
                                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                        
                                                        
                                                        if let trackName = json["name"] as? String {
                                                            print("TRACK NAME: ", trackName)
                                                            feedPost.track.name = trackName
                                                            print("TRACK: ", json["name"] as? String)
                                                        }
                                                        
                                                        if let trackUri = json["uri"] as? String {
                                                            feedPost.track.uri = trackUri
                                                        }
                                                        
                                                        if let artists = json["artists"] as? [[String: Any]] {
                                                            if let artist = artists[0] as? [String: Any] {
                                                                if let artistName = artist["name"] as? String {
                                                                    feedPost.track.album.artist.name = artistName
                                                                }
                                                            }
                                                        }
                                                        
                                                        if let album = json["album"] as? [String: Any] {
                                                            if let images = album["images"] as? [[String: Any]] {
                                                                if let imageUrl = images[1]["url"] as? String {
                                                                    
                                                                    feedPost.track.album.image = imageUrl
                                                                }
                                                            }
                                                        }
                                                        
                                                        DispatchQueue.main.async {
                                                            UserFeed.addPost(post: feedPost)
                                                            UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                                                            for post in UserFeed.posts {
                                                                print(post.id)
                                                            }
                                                            print("")
                                                            self.tableView.reloadData()
                                                        }
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
                    } else if feedPost.type == "album" {
                        
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
                                        var requestUrl = "https://api.spotify.com/v1/albums/"
                                        requestUrl += feedPost.albumId!
                                        
                                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                        
                                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                                            if let data = data {
                                                do {
                                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                        
                                                        if let albumName = json["name"] as? String {
                                                            feedPost.album.name = albumName
                                                        }
                                                        
                                                        if let artists = json["artists"] as? [[String: Any]] {
                                                            if let artist = artists[0] as? [String: Any] {
                                                                if let artistName = artist["name"] as? String {
                                                                    feedPost.album.artist.name = artistName
                                                                }
                                                            }
                                                        }
                                                        
                                                        if let images = json["images"] as? [[String: Any]] {
                                                            if let imageUrl = images[1]["url"] as? String {
                                                                feedPost.album.image = imageUrl
                                                            }
                                                        }
                                                    }
                                                    DispatchQueue.main.async {
                                                        UserFeed.posts.append(feedPost)
                                                        //                                                        UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                                                        //                                                        for post in UserFeed.posts {
                                                        //                                                            print(post.id)
                                                        //                                                        }
                                                        //                                                        print("")
                                                        //                                                        self.tableView.reloadData()
                                                    }
                                                    
                                                    
                                                } catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        }
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            }.resume()
                        
                    } else {
                        UserFeed.addPost(post: feedPost)
                        //                        UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                        //                        for post in UserFeed.posts {
                        //                            print(post.id)
                        //                        }
                        //                        print("")
                        //                        self.tableView.reloadData()
                    }
                    
                }
                UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                self.tableView.reloadData()
                
            }
        } catch {
            print(error.localizedDescription)
        }
 
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            if json["response"] as? String == "feed" {
                UserFeed.posts.removeAll()
                print(json)
                let feed = json["feed"] as! [[String: Any]]
                
                // Create new post for each item and add to user's feed
                for item in feed {
                    // Get the user info who posted
                    let postUser = User()
                    postUser.displayName = item["post_user_displayname"] as! String
                    postUser.username = item["post_user_id"] as! String
                    postUser.username = "@" + postUser.username
                    postUser.imageUrl = item["post_user_imageurl"] as! String
                    
                    let feedPost = Post()
                    feedPost.albumId = item["post_album_id"] as! String
                    feedPost.message = item["post_message"] as! String
                    feedPost.timestamp = item["post_timestamp"] as! String
                    feedPost.trackId = item["post_song_id"] as! String
                    feedPost.type = item["post_type"] as! String
                    feedPost.id = item["post_id"] as! String
                    feedPost.user = postUser
                    
                    
                    if feedPost.type == "song" {
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
                                        requestUrl += feedPost.trackId!
                        
                                        
                                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                        
                                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                                            if let data = data {
                                                do {
                                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                        
                                                        
                                                        if let trackName = json["name"] as? String {
                                                            print("TRACK NAME: ", trackName)
                                                            feedPost.track.name = trackName
                                                            print("TRACK: ", json["name"] as? String)
                                                        }
                                                        
                                                        if let trackUri = json["uri"] as? String {
                                                            feedPost.track.uri = trackUri
                                                        }
                                                        
                                                        if let artists = json["artists"] as? [[String: Any]] {
                                                            if let artist = artists[0] as? [String: Any] {
                                                                if let artistName = artist["name"] as? String {
                                                                    feedPost.track.album.artist.name = artistName
                                                                }
                                                            }
                                                        }
                                                        
                                                        if let album = json["album"] as? [String: Any] {
                                                            if let images = album["images"] as? [[String: Any]] {
                                                                if let imageUrl = images[1]["url"] as? String {
                                                                   
                                                                    feedPost.track.album.image = imageUrl
                                                                }
                                                            }
                                                        }
                                                        
                                                        DispatchQueue.main.async {
                                                            UserFeed.addPost(post: feedPost)
                                                            UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                                                            for post in UserFeed.posts {
                                                                print(post.id)
                                                            }
                                                            print("")
                                                            self.tableView.reloadData()
                                                        }
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
                    } else if feedPost.type == "album" {
                        
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
                                        var requestUrl = "https://api.spotify.com/v1/albums/"
                                        requestUrl += feedPost.albumId!
                                        
                                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                        
                                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                                            if let data = data {
                                                do {
                                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                        
                                                        if let albumName = json["name"] as? String {
                                                            feedPost.album.name = albumName
                                                        }
                                                        
                                                        if let artists = json["artists"] as? [[String: Any]] {
                                                            if let artist = artists[0] as? [String: Any] {
                                                                if let artistName = artist["name"] as? String {
                                                                    feedPost.album.artist.name = artistName
                                                                }
                                                            }
                                                        }
                                                        
                                                        if let images = json["images"] as? [[String: Any]] {
                                                            if let imageUrl = images[1]["url"] as? String {
                                                                feedPost.album.image = imageUrl
                                                            }
                                                        }
                                                    }
                                                    DispatchQueue.main.async {
                                                        UserFeed.posts.append(feedPost)
//                                                        UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
//                                                        for post in UserFeed.posts {
//                                                            print(post.id)
//                                                        }
//                                                        print("")
//                                                        self.tableView.reloadData()
                                                    }
                                                    
                                                    
                                                } catch {
                                                    print(error.localizedDescription)
                                                }
                                            }
                                        }
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }.resume()
                        
                    } else {
                        UserFeed.addPost(post: feedPost)
//                        UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
//                        for post in UserFeed.posts {
//                            print(post.id)
//                        }
//                        print("")
//                        self.tableView.reloadData()
                    }
                    
                }
                UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                self.tableView.reloadData()

            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print(json)
            
            // User followers response
            if json["response"] as? String == "post_added" {
                print("PLEASE")
                let postUser = User()
                postUser.displayName = json["post_user_displayname"] as! String
                postUser.username = json["post_user_id"] as! String
                postUser.username = "@" + postUser.username
                postUser.imageUrl = json["post_user_imageurl"] as! String
                
                var feedPost = Post()
                feedPost.albumId = json["post_album_id"] as! String
                feedPost.message = json["post_message"] as! String
                feedPost.timestamp = json["post_timestamp"] as! String
                feedPost.trackId = json["post_song_id"] as! String
                feedPost.type = json["post_type"] as! String
                feedPost.user = postUser
                
                UserFeed.addPost(post: feedPost)
                UserFeed.posts = UserFeed.posts.sorted{ $0.id > $1.id }
                for post in UserFeed.posts {
                    print(post.id)
                }
                print("")
                tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
        
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
}
