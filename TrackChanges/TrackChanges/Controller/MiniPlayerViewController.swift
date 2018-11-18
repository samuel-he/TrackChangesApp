//
//  MiniPlayerViewController.swift
//  TrackChanges
//
//  Created by Pavly Habashy on 11/15/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

// TODO: Put all this in one file
protocol MiniPlayerDelegate: class {
    func expandSong(song: Track)
}

class PlayPauseButton: UIButton {
    var isPlaying = false
}

var AppRemote: SPTAppRemote {
    get {
        return AppDelegate.sharedInstance.appRemote
    }
}

var PlayerState: SPTAppRemotePlayerState?
// END OF TODO

class MiniPlayerViewController: UIViewController, SPTAppRemotePlayerStateDelegate {
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    var currentSong: Track?
    weak var delegate: MiniPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPlayerState()
        
        // Add shadow to the album cover art in the mini player
        self.thumbImage.layer.shadowColor = UIColor.black.cgColor
        self.thumbImage.layer.shadowOpacity = 0.5
        self.thumbImage.layer.shadowOffset = CGSize.zero
        self.thumbImage.layer.shadowRadius = 2
        self.thumbImage.layer.shouldRasterize = true
        
        // Add a top border to the mini player
        self.view.addTopBorder(color: UIColor.lightGray, width: 0.2)
        
        // Round the album cover art in the mini player (NOT WORKING)
        //        miniPlayer?.thumbImage.layer.cornerRadius = 3.0
        //        miniPlayer?.thumbImage.clipsToBounds = true
        //        currentSong = Track()
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        AppRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            
            if playerState.isPaused {
                
//                AppRemote.playerAPI?.play(TrackIdentifier, callback: { (track, error) in
//                    print(error?.localizedDescription as Any)
//                })
                
//                AppRemote.playerAPI?.play(TrackIdentifier, callback: { (track, error) in
//                    print(error?.localizedDescription as Any)
//                })
                
                AppRemote.playerAPI?.resume()
                
                
                
                
                
                self.playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
            } else if !playerState.isPaused {
                
                AppRemote.playerAPI?.pause({ (track, error) in
                    print(error?.localizedDescription as Any)
                })
                
                
                
                
                
                self.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
            }
        }
    }
    
    func updateAlbumArtWithImage(_ image: UIImage) {
        self.thumbImage.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.thumbImage.layer.add(transition, forKey: "transition")
    }
    
    // Delegate method that checks for a player state change and updates the mini player
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        PlayerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    // Fetch album art for a certain track with a given width and height
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        AppRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 200, height: 200), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
    // Gets player state, updates playerState, and updates mini player
    func getPlayerState() {
        AppRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
    }
    
    func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        songTitle.text = playerState.track.name
        nowPlayingArtist.text = playerState.track.artist.name
        
        // IMPORTANT
//        AppRemote.playerAPI?.play("spotify:album:6mLrBrgyQu0wLqsWBoN9j2")
        
        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
            self.updateAlbumArtWithImage(image)
        }
        
        if playerState.isPaused {
            self.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
        } else if !playerState.isPaused {
            self.playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        }
    }
}

// MARK: - Internal
extension MiniPlayerViewController {
    /*
    func configure(song: Track?) {
        
        if let song = song {
            songTitle.text = song.name
            nowPlayingArtist.text = song.artist
            thumbImage.image = song.image
        } else {
            songTitle.text = nil
            nowPlayingArtist.text = nil
            thumbImage.image = nil
        }
        currentSong = song
    }
    */
}


