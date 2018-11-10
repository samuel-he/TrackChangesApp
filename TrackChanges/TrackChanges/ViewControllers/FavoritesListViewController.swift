//
//  FavoritesListViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 11/4/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class FavoritesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var displayTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getPlayerState()
    }
    
    /******
    *** Function to return to previous screen
    ******/
    
    @IBAction func previous(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check which category was selected on the previous screen
        if FavoritesDisplayCategory == 0 {
            displayTitle.text = "Songs"
        } else if FavoritesDisplayCategory == 1 {
            displayTitle.text = "Albums"
        } else {
            displayTitle.text = "Shared"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Display the cells based on the list category
        if FavoritesDisplayCategory == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongSearchTableViewCell
            return cell
        } else if FavoritesDisplayCategory == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumSearchTableViewCell
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if FavoritesDisplayCategory == 1 {
            self.performSegue(withIdentifier: "FavoritesListToAlbum", sender: nil)
        }
    }
    
    // MARK: Update now playing view
    
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
        transition.type = kCATransitionFade
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
