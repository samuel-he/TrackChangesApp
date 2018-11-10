//
//  ConnectViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/27/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer

let PlayURI = "spotify:album:5uMfshtC2Jwqui0NUyUYIL"
let TrackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"

class ConnectViewController: UIViewController, SPTAppRemotePlayerStateDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        PlayerState = playerState
    }
    
    @IBOutlet weak var connectButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Edit connect button
        connectButton.layer.cornerRadius = 20
        let title = NSAttributedString.init(string: "CONNECT", attributes: [NSAttributedStringKey.kern: 2, NSAttributedStringKey.foregroundColor: UIColor.white])
        connectButton.setAttributedTitle(title, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    @IBAction func connectToSpotify(_ sender: Any) {
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
