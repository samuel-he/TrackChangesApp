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

class ConnectViewController: UIViewController, SPTAppRemotePlayerStateDelegate,
    SPTAppRemoteUserAPIDelegate,
SKStoreProductViewControllerDelegate {
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    // MARK: - <SPTAppRemoteUserAPIDelegate>
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
//        updateViewWithCapabilities(capabilities)
    }
    

    @IBOutlet weak var connectButton: UIButton!
    
//    let SpotifyClientID = "4bebf0c82b774aaa99764eb7c5c58cc4"
//    let SpotifyRedirectURL = URL(string: "trackchanges://spotify-login-callback/")!
    
    fileprivate let playURI = "spotify:album:5uMfshtC2Jwqui0NUyUYIL"
    fileprivate let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    fileprivate let name = "Now Playing View"
    
    
    fileprivate func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
//        updatePlayPauseButtonState(playerState.isPaused)
//        updateRepeatModeLabel(playerState.playbackOptions.repeatMode)
//        updateShuffleLabel(playerState.playbackOptions.isShuffling)
//        trackNameLabel.text = playerState.track.name + " - " + playerState.track.artist.name
//        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
//            self.updateAlbumArtWithImage(image)
//        }
//        updateViewWithRestrictions(playerState.playbackRestrictions)
    }

    
//    lazy var configuration = SPTConfiguration(
//        clientID: SpotifyClientID,
//        redirectURL: SpotifyRedirectURL
//    )
//
//    lazy var sessionManager: SPTSessionManager = {
//        if let tokenSwapURL = URL(string: "https://trackchanges.herokuapp.com/api/token"),
//            let tokenRefreshURL = URL(string: "https://trackchanges.herokuapp.com/api/refresh_token") {
//            self.configuration.tokenSwapURL = tokenSwapURL
//            self.configuration.tokenRefreshURL = tokenRefreshURL
//            self.configuration.playURI = ""
//        }
//        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
//        return manager
//    }()
//
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
//        appRemote.delegate = self
//        return appRemote
//    }()
    
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
//        let requestedScopes: SPTScope = [.appRemoteControl]
//        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        
        if !(appRemote.isConnected) {
            if (!appRemote.authorizeAndPlayURI(playURI)) {
                // The Spotify app is not installed, present the user with an App Store page
//                showAppStoreInstall()
            }
        } else if playerState == nil || playerState!.isPaused {
            startPlayback()
        } else {
            pausePlayback()
        }
    }

    fileprivate var playerState: SPTAppRemotePlayerState?
    
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }
    
    fileprivate func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }
    
    fileprivate func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }

    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
//                    self?.displayError(error as NSError)
                }
            }
        }
}

//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        self.sessionManager.application(app, open: url, options: options)
//        return true
//    }
//
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        print("success", session)
//        self.appRemote.connectionParameters.accessToken = session.accessToken
//        self.appRemote.connect()
//    }
//
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print("fail", error)
//    }
//
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        print("renewed", session)
//    }
//
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        print("connected")
//        self.appRemote.playerAPI?.delegate = self
//        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//            }
//        })
//
//        if appRemote.isConnected {
//            self.performSegue(withIdentifier: "GoToFeed", sender: nil)
//        } else {
//            print("-----NOT CONNECTED------")
//        }
//    }
//    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        print("disconnected")
//    }
//    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        print("failed")
//    }
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        print("player state changed")
//    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
