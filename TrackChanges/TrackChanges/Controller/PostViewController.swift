//
//  PostViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/15/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream

var SharePost = Int()
var ShareTrack = Track()
var ShareAlbum = Album()

class PostViewController: UIViewController, UITextViewDelegate, WebSocketDelegate {

    
//    var socket2: WebSocket!
    
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var shareContent: UIView!
    @IBOutlet weak var shareAlbumCover: UIImageView!
    @IBOutlet weak var shareTitle: UILabel!
    @IBOutlet weak var shareArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
    }
    
    // Dismiss PostViewController
    @IBAction func exitPost(_ sender: Any) {
        SharePost = Int()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: Any) {
 
        let newPost = Post()
        newPost.message = postText.text
        
        if SharePost == 1 {
            let json:NSMutableDictionary = NSMutableDictionary()
            
            json.setValue("add_post", forKey: "request")
            json.setValue(currentUser.username, forKey: "post_user_id")
            json.setValue(newPost.timestamp, forKey: "post_timestamp")
            json.setValue(newPost.message, forKey: "post_message")
            json.setValue(ShareTrack.id, forKey: "post_song_id")
            json.setValue("", forKey: "post_album_id")
            json.setValue("song", forKey: "post_type")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            print(jsonString)
            
            socket.write(data: jsonData)
        } else if SharePost == 2 {
            let json:NSMutableDictionary = NSMutableDictionary()
            
            json.setValue("add_post", forKey: "request")
            json.setValue(currentUser.username, forKey: "post_user_id")
            json.setValue(newPost.timestamp, forKey: "post_timestamp")
            json.setValue(newPost.message, forKey: "post_message")
            json.setValue("", forKey: "post_song_id")
            json.setValue(ShareAlbum.id, forKey: "post_album_id")
            json.setValue("album", forKey: "post_type")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            print(jsonString)
            
            socket.write(data: jsonData)
        } else {
            
            let json:NSMutableDictionary = NSMutableDictionary()
            
            json.setValue("add_post", forKey: "request")
            json.setValue(currentUser.username, forKey: "post_user_id")
            json.setValue(newPost.timestamp, forKey: "post_timestamp")
            json.setValue(newPost.message, forKey: "post_message")
            json.setValue("", forKey: "post_song_id")
            json.setValue("", forKey: "post_album_id")
            json.setValue("regular", forKey: "post_type") 
            
            let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            print(jsonString)
            
            socket.write(data: jsonData)
        }
        
        exitPost(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        socket.delegate = self
        
        // Check if someone is sharing music 
        if SharePost == 1 || SharePost == 2 {
            shareContent.isHidden = false
        } else {
            shareContent.isHidden = true 
        }
        
        // Sharing a track
        if SharePost == 1 {
            playPauseButton.isHidden = false
            
            shareTitle.text = ShareTrack.name
            shareArtist.text = ShareTrack.album.artist.name
            
            shareAlbumCover.contentMode = .scaleAspectFit
            let url = URL.init(string: ShareTrack.album.image)!
            do {
                let data = try Data(contentsOf: url)
                shareAlbumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            // Sharing an album
        } else if SharePost == 2 {
            playPauseButton.isHidden = true
            
            shareTitle.text = ShareAlbum.name
            shareArtist.text = ShareAlbum.artist.name
            
            shareAlbumCover.contentMode = .scaleAspectFit
            let url = URL.init(string: ShareAlbum.image)!
            do {
                let data = try Data(contentsOf: url)
                shareAlbumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        postText.text = "What are you listening to?"
        postText.textColor = UIColor.lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        postText.becomeFirstResponder()
        postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        postText.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            postText.text = "What are you listening to?"
            postText.textColor = UIColor.lightGray
            
            postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
        } else if postText.textColor == UIColor.lightGray && !text.isEmpty {
            postText.textColor = UIColor.black
            postText.text = text
        } else {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if postText.textColor == UIColor.lightGray {
                postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
            }
        }
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
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print(json)
        } catch {
            print(error.localizedDescription)
        }
    }
}
