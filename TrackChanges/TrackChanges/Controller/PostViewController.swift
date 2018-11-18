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
        
        
        
        // PJ
//        var request2 = URLRequest(url: URL(string: "ws://172.20.10.3:8080/TrackChangesBackend/endpoint")!)
//        request2.timeoutInterval = 5
//        socket2 = WebSocket(request: request2)
//        socket2.delegate = self
//        socket2.connect()
        
    }
    
    
    
//    func send(_ value: Any) {
//
//        guard JSONSerialization.isValidJSONObject(value) else {
//            print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
//            return
//        }
//
//        if JSONSerialization.isValidJSONObject(value) { // True
//            do {
//                let rawData = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
//                print(rawData)
////                print(value)
//                socket.write(data: rawData)
//
//            } catch let error {
//                print("[WEBSOCKET] Error serializing JSON:\n\(error)")
//            }
//        }
//    }
    
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
    }
    
    // Dismiss PostViewController
    @IBAction func exitPost(_ sender: Any) {
        SharePost = Int()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: Any) {
        
        let json:NSMutableDictionary = NSMutableDictionary()
        
        let json1:NSMutableArray = NSMutableArray()
        
        json1.add("image")
        json1.add("email")
        
        json.setValue("getFeed", forKey: "request")
        json.setObject(json1, forKey: "items" as NSCopying)

        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)
        
        
//        if SharePost == 1 {
//
//        } else if SharePost == 2 {
//
//        } else {
//            var newPost = Post(message: postText.text)
//
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if someone is sharing music 
        if SharePost == 1 || SharePost == 2 {
            shareContent.isHidden = false
        } else {
            shareContent.isHidden = true 
        }
        
        if SharePost == 2 {
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
            
        } else if SharePost == 1 {
            playPauseButton.isHidden = false
            
            shareTitle.text = ShareTrack.name
            shareArtist.text = ShareTrack.album.artist.name
            
            shareAlbumCover.contentMode = .scaleAspectFit
//            let url = URL.init(string: ShareTrack.album.image)!
//            do {
//                let data = try Data(contentsOf: url)
//                shareAlbumCover.image = UIImage.init(data: data)
//            } catch {
//                print(error.localizedDescription)
//            }
            
        }
        
        postText.text = "What are you listening to?"
        postText.textColor = UIColor.lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        postText.becomeFirstResponder()
        
        postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
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
}
