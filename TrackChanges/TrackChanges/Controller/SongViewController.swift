//
//  SongViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class SongViewController: UIViewController, SPTAppRemotePlayerStateDelegate {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerState()
    }
    
    func updateAlbumArtWithImage(_ image: UIImage) {
        // Add shadow to the album cover art in the mini player
        self.albumCover.layer.shadowColor = UIColor.black.cgColor
        self.albumCover.layer.shadowOpacity = 0.5
        self.albumCover.layer.shadowOffset = CGSize.zero
        self.albumCover.layer.shadowRadius = 5
        self.albumCover.layer.shouldRasterize = true
        
        // Add a top border to the mini player
        self.view.addTopBorder(color: UIColor.lightGray, width: 0.2)
        self.albumCover.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.albumCover.layer.add(transition, forKey: "transition")
    }
    
    // Delegate method that checks for a player state change and updates the mini player
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        PlayerState = playerState
        getPlayerState()
    }
    
    // Fetch album art for a certain track with a given width and height
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        AppRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 2000, height: 2000), callback: { (image, error) -> Void in
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
        artist.text = playerState.track.artist.name
        
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
    
    /****
    ** Close the view of the song
    ****/
    
    @IBAction func closeSongView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /****
    ** Create a post about the song
    ****/
    
    @IBAction func postSong(_ sender: Any) {
        SharePost = 1
    }
    
    @IBAction func playAndPauseSong(_ sender: Any) {
        AppRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            if playerState.isPaused {
                AppRemote.playerAPI?.resume()
                self.playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
            } else {
                AppRemote.playerAPI?.pause({ (track, error) in
                    print(error?.localizedDescription)
                })
                self.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
//                UIView.animate(withDuration: 0.7, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
////                    self.albumCover.frame = CGRect(x: self.albumCover.frame.midY, y: self.albumCover.frame.midX, width: 100, height: 100)
//                }, completion: nil)
            }
        }
    }
    
    @IBAction func playNextSong(_ sender: Any) {
        AppRemote.playerAPI?.skip(toNext: { (track, error) in
            print(error?.localizedDescription)
        })
        
        usleep(80000)
        getPlayerState()
        
    }
    
    @IBAction func playPreviousSong(_ sender: Any) {
        AppRemote.playerAPI?.skip(toPrevious: { (track, error) in
            print(error?.localizedDescription)
        })
        
        usleep(80000)
        getPlayerState()
        
    }

}
