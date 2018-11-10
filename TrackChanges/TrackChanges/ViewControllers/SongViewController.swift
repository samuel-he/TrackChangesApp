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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPlayerState()
    }
    
    func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        songTitle.text = playerState.track.name
        artist.text = playerState.track.artist.name
        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
            self.updateAlbumArtWithImage(image)
        }
        
        if playerState.isPaused {
            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        }
    }
    
    func updateAlbumArtWithImage(_ image: UIImage) {
        self.albumCover.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.albumCover.layer.add(transition, forKey: "transition")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        PlayerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        AppRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 250, height: 250), callback: { (image, error) -> Void in
            guard error == nil else { return }
            
            let image = image as! UIImage
            callback(image)
        })
    }
    
    func getPlayerState() {
        AppRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
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
        SharePost = true
        ShareTitle = (songTitle.text as? String)!
        ShareAlbum = albumCover.image!
        ShareArtist = (artist.text as? String)!
//        ShareTrackID = TrackIdentifier
    }
    
    @IBAction func playAndPauseSong(_ sender: Any) {
        if PlayerState!.isPaused {
            AppRemote.playerAPI?.play(TrackIdentifier, callback: { (track, error) in
                print(error?.localizedDescription)
            })
            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        } else {
            AppRemote.playerAPI?.pause({ (track, error) in
                print(error?.localizedDescription)
            })
            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
        }
    }
    
    @IBAction func playNextSong(_ sender: Any) {
        
    }
    
    @IBAction func playPreviousSong(_ sender: Any) {
     
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
