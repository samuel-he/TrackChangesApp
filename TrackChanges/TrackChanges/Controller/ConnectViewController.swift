//
//  ConnectViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/27/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream


class ConnectViewController: UIViewController, WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket connected")
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
        let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        print(jsonString)
    }
    

    
    @IBOutlet weak var connectButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        // Edit connect button
        connectButton.layer.cornerRadius = 20
        let title = NSAttributedString.init(string: "CONNECT", attributes: [NSAttributedString.Key.kern: 2, NSAttributedString.Key.foregroundColor: UIColor.white])
        connectButton.setAttributedTitle(title, for: .normal)
    }
    
    
    @IBAction func connectToSpotify(_ sender: Any) {
        GuestUser = false 
        if !AppRemote.isConnected {
            if !AppRemote.authorizeAndPlayURI(PlayURI) {
                // The Spotify app is not installed, present the user with an App Store page
//                showAppStoreInstall()
            }
        } else if PlayerState == nil || PlayerState!.isPaused {
            startPlayback()
        } else {
            pausePlayback()
        }
    }
    
    @IBAction func connectAsGuest(_ sender: Any) {
        GuestUser = true
//        self.appRemote = appRemote
        //        feedViewController.miniPlayer?.getPlayerState()
        self.performSegue(withIdentifier: "GoToFeed", sender: nil)
    }
    
    fileprivate func startPlayback() {
        AppRemote.playerAPI?.resume(defaultCallback)
    }
    
    fileprivate func pausePlayback() {
        AppRemote.playerAPI?.pause(defaultCallback)
    }

    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

}
