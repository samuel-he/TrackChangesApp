//
//  FeedViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/13/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class PlayPauseButton: UIButton {
    var isPlaying = false
}

var AppRemote: SPTAppRemote {
    get {
        return AppDelegate.sharedInstance.appRemote
    }
}

var PlayerState: SPTAppRemotePlayerState?

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SPTAppRemotePlayerStateDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var feedTitleLabel: UILabel!
//    var tapToTheTop: UITapGestureRecognizer!
    @IBOutlet weak var nowPlayerView: UIView!
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    navigationController?.navigationBar.prefersLargeTitles = true

        // Do any additional setup after loading the view.
        
        // Add gesture recognizer to move to the top on click
//        tapToTheTop = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
//        feedTitleLabel.addGestureRecognizer(tapToTheTop)
        
//        tableView.estimatedRowHeight = 365
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get info about current playing song
        getPlayerState()
    }
    
    /*****
    **** Tap to reload to top of the screen
    *****/
    @objc func scrollToTop() {
        tableView.setContentOffset(.zero, animated: true)
    }
    
    
    @IBAction func playAndPauseSong(_ sender: Any) {
        AppRemote.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            
            let playerState = result as! SPTAppRemotePlayerState
            if playerState.isPaused {
                AppRemote.playerAPI?.play(TrackIdentifier, callback: { (track, error) in
                    print(error?.localizedDescription)
                })
                self.playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
            } else {
                AppRemote.playerAPI?.pause({ (track, error) in
                    print(error?.localizedDescription)
                })
                self.playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
            }
        }
    }
    
    // Create a post 
    @IBAction func createPost(_ sender: Any) {
        self.performSegue(withIdentifier: "StartPost", sender: nil) 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        // Set the image for the play/pause button
        if cell.playPauseButton.isPlaying {
            cell.playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        } else {
            cell.playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
        }
        // Add a tag to identify which cell was selected
        cell.playPauseButton.tag = indexPath.row
        return cell
    }
    
    // MARK: Update Now Playing 
    
    func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        self.nowPlayingTitle.text = playerState.track.name
        self.nowPlayingArtist.text = playerState.track.artist.name
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
        self.nowPlayingImage.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        self.nowPlayingImage.layer.add(transition, forKey: "transition")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        self.PlayerState = playerState
        PlayerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        AppRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 50, height: 50), callback: { (image, error) -> Void in
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
