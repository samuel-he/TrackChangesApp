
//
//  SearchResultsViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var songsButton: UIButton!
    @IBOutlet weak var albumsButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set tableView background color
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Change cancel button color
        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
    }
 
    /****
    *** Filters search results
    ****/
    
    @IBAction func switchTab(_ sender: UIButton) {
        switch sender.tag {
            
        case 1:
            allButton.setTitleColor(UIColor.black, for: .normal)
        case 2:
            songsButton.setTitleColor(UIColor.black, for: .normal)
        case 3:
            albumsButton.setTitleColor(UIColor.black, for: .normal)
        case 4:
            peopleButton.setTitleColor(UIColor.black, for: .normal)
        default:
            return
        }
    }
    
    /////
    // Go back to the previous screen
    /////
    
    @IBAction func previous(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "SearchHeader") as! SearchResultsTitleTableViewCell
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check which kind of cell was tapped
        if let cell = tableView.cellForRow(at: indexPath) as? PeopleSearchTableViewCell {
            // Go to person's profile
            self.performSegue(withIdentifier: "SearchResultsToProfile", sender: nil)
        } else if let cell = tableView.cellForRow(at: indexPath) as? SongSearchTableViewCell {
            print("Song")
        } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumSearchTableViewCell {
            self.performSegue(withIdentifier: "SearchResultsToAlbum", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleSearchTableViewCell
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongSearchTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumSearchTableViewCell
            return cell
        }
    }
    
    
    /*
 
        Handle Search Bar
 
    */
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        view.endEditing(true)
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
