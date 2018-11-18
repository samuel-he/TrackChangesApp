//
//  ConnectViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/27/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

var GuestUser = Bool()

let PlayURI = ""
let TrackIdentifier = ""

class ConnectViewController: UIViewController, SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        PlayerState = playerState
    }
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
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
