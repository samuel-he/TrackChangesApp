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
var socket: WebSocket!

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebSocketDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Mini player stuff
    var miniPlayer: MiniPlayerViewController?
    var currentSong: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup a socket to backend
        var request = URLRequest(url: URL(string: "ws://172.20.10.4:8080/TrackChangesBackend/endpoint")!)
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
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let imageURL = URL(string: currentUser.imageUrl)!
        
        // Downloads profile image
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: imageURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        currentUser.image = UIImage(data: imageData)
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
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
    
    // Segue for miniplayer
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "miniPlayer", let destination = segue.destination as? MiniPlayerViewController {
//            miniPlayer = destination
//            miniPlayer?.delegate = self as? MiniPlayerDelegate
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        // Set the image for the play/pause button
        if cell.playPauseButton.isPlaying {
            cell.playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        } else {
            cell.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
        }
        
        // Add a tag to identify which cell was selected
        cell.playPauseButton.tag = indexPath.row
        return cell
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
    }
    
}

