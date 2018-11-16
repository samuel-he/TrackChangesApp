
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
//    @IBOutlet weak var searchBar: UISearchBar!
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
//        tableView.backgroundView = nil
//        tableView.backgroundColor = UIColor.white
        
        getPlayerState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Change cancel button color
//        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
//        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
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
        // Clear search results
        
        navigationController?.popViewController(animated: true)
    }
    
    func parseAlbum(json: [String: Any], selectedAlbum: Album) {
        var albumTracks = [Track]()
        
        if let items = json["items"] as? [[String: Any]] {
            for item in items {
                
                var trackInAlbum = Track()
                
                //  Get track
                if let trackName = item["name"] as? String {
                    trackInAlbum.name = trackName
                }
                if let trackUri = item["uri"] as? String {
                    trackInAlbum.uri = trackUri
                }
                if let trackId = item["id"] as? String {
                    trackInAlbum.id = trackId
                }
                // Add the track to the list of album tracks
                albumTracks.append(trackInAlbum)
            }
        }
        // Add the tracks to the selected album
        SelectedAlbum.tracks = albumTracks
        
        for track in SelectedAlbum.tracks {
            track.album = SelectedAlbum
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "SearchHeader") as! SearchResultsTitleTableViewCell
        if section == 0 {
            header.sectionTitle.text = "Songs"
        } else if section == 1 {
            header.sectionTitle.text = "Albums"
        } else if section == 2 {
            header.sectionTitle.text = "People"
        }
        return header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return TrackResults.count
        } else if section == 1 {
            return AlbumResults.count
        } else if section == 2 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check which kind of cell was tapped
        if let cell = tableView.cellForRow(at: indexPath) as? PeopleSearchTableViewCell {
            // Go to person's profile
            self.performSegue(withIdentifier: "SearchResultsToProfile", sender: nil)
        } else if let cell = tableView.cellForRow(at: indexPath) as? SongSearchTableViewCell {
            
            // Play the song selected
            AppRemote.playerAPI?.play(TrackResults[indexPath.row].uri, callback: { (track, error) in
                print(error?.localizedDescription)
            })
            // Update the player
            getPlayerState()
            
        } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumSearchTableViewCell {
            
            // Set the selected album for the album screen
            SelectedAlbum = AlbumResults[indexPath.row]
        
            // Request accecssToken
            let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
            let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
            
            let tokenUrl = "https://accounts.spotify.com/api/token"
            var albumUrl = "https://api.spotify.com/v1/albums/"
            
            // Request access token to make search requests
            var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
            tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
            tokenRequest.httpMethod = "POST"
            
            var accessToken = String()
            
            URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            accessToken = (json["access_token"] as? String)!
                            
                            // Make request to get tracks for SelectedAlbum 
                                albumUrl += AlbumResults[indexPath.row].id
                                albumUrl += "/tracks"
                            
                            var albumRequest = URLRequest(url: URL.init(string: albumUrl)!)
                            albumRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                
                                URLSession.shared.dataTask(with: albumRequest) { (data, response, error) in
                                    if let data = data {
                                        do {
                                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                self.parseAlbum(json: json, selectedAlbum: SelectedAlbum)
                                                
                                                // Finished loading data, move to next screen
                                                DispatchQueue.main.async {
                                                               self.performSegue(withIdentifier: "SearchResultsToAlbum", sender: nil)
                                                }

                                            }
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }.resume()
                        
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongSearchTableViewCell
            // Set song title
            cell.songTitle.text = TrackResults[indexPath.row].name
            // Set artist name
            cell.artist.text = TrackResults[indexPath.row].album.artist.name
            
            // Set album cover
            cell.albumCover.contentMode = .scaleAspectFit
            // Get image
            let url = URL.init(string: TrackResults[indexPath.row].album.image)!
            do {
                let data = try Data(contentsOf: url)
                cell.albumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumSearchTableViewCell
            // Set album title
            cell.albumTitle.text = AlbumResults[indexPath.row].name
            // Set artist name
            cell.artist.text = AlbumResults[indexPath.row].artist.name
            
            cell.albumCover.contentMode = .scaleAspectFit
            let url = URL.init(string: AlbumResults[indexPath.row].image)!
            do {
                let data = try Data(contentsOf: url)
                cell.albumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleSearchTableViewCell
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    // MARK: SEARCH FUNCTIONALITY
    
    
    /**
     * Function to parse track json from Spotify
     **/
    
    func parseTracks(json: [String: Any]) {
        if let tracks = json["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                
                for track in items {
                    
                    var trackResult = Track()
                    
                    // Get track info
                    if let uri = track["uri"] as? String {
                        trackResult.uri = uri
                    }
                    if let name = track["name"] as? String {
                        trackResult.name = name
                    }
                    
                    if let trackId = track["id"] as? String {
                        trackResult.id = trackId
                    }
                    
                    var albumForTrack = Album()
                    
                    var artistForAlbum = Artist()
                    
                    // Get the artist of the track
                    if let album = track["album"] as? [String: Any] {
                        if let albumName = album["name"] as? String {
                            albumForTrack.name = albumName
                        }
                        if let albumUri = album["uri"] as? String {
                            albumForTrack.uri = albumUri
                        }
                        
                        if let albumId = album["id"] as? String {
                            albumForTrack.id = albumId
                        }
                        
                        if let artists = album["artists"] as? [[String: Any]] {
                            // Get artist name
                            if let artistName = artists[0]["name"] as? String {
                                artistForAlbum.name = artistName
                            }
                            // Get artist uri
                            if let artistUri = artists[0]["uri"] as? String {
                                artistForAlbum.uri = artistUri
                            }
                            // Get artist id
                            if let artistId = artists[0]["id"] as? String {
                                artistForAlbum.id = artistId
                            }
                        }
                        
                        albumForTrack.artist = artistForAlbum
                        
                        // Get album cover
                        if let images = album["images"] as? [[String: Any]] {
                            if let url = images[0]["url"] as? String {
                                albumForTrack.image = url
                            }
                        }
                    }
                    
                    // Add album to track
                    trackResult.album = albumForTrack
                    
                    // Add results to track results
                    TrackResults.append(trackResult)
                    
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /**
     * Function to parse album json from Spotify
     **/
    
    func parseAlbums(json: [String: Any]) {
        if let albums = json["albums"] as? [String: Any] {
            if let items = albums["items"] as? [[String: Any]] {
                for album in items {
                    
                    var albumResult = Album()
                    
                    if let uri = album["uri"] as? String {
                        albumResult.uri = uri
                    }
                    if let name = album["name"] as? String {
                        albumResult.name = name
                    }
                    
                    if let albumId = album["id"] as? String {
                        albumResult.id = albumId
                    }
                    
                    var artistForAlbum = Artist()
                    
                    if let artists = album["artists"] as? [[String: Any]] {
                        if let artistName = artists[0]["name"] as? String {
                            artistForAlbum.name = artistName
                        }
                        if let artistUri = artists[0]["uri"] as? String {
                            artistForAlbum.uri = artistUri
                        }
                        
                        if let artistId = artists[0]["id"] as? String {
                            artistForAlbum.id = artistId
                        }
                    }
                    
                    // Add artist to the album
                    albumResult.artist = artistForAlbum
                    
                    if let images = album["images"] as? [[String: Any]] {
                        if let url = images[0]["url"] as? String {
                            albumResult.image = url
                        }
                    }
                    
                
                    AlbumResults.append(albumResult)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var tokenUrl = "https://accounts.spotify.com/api/token"
    // Base url for spotify search
    var searchUrl = "https://api.spotify.com/v1/search?q="
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Clear search results
        TrackResults.removeAll()
        AlbumResults.removeAll()
        
        // Request accecssToken
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        
        // Request access token to make search requests
        var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
        tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        tokenRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let accessToken = (json["access_token"] as? String)!
                        
                        // MARK: SEARCH
                        
                        DispatchQueue.main.async {
                            // Get search parameter
                            self.searchUrl += searchBar.text!
                            self.searchUrl += "&type=album,artist,track"
                            self.searchUrl += "&limit=25"
                            self.searchUrl = self.searchUrl.replacingOccurrences(of: " ", with: "%20")
                            
                            var searchRequest = URLRequest(url: URL.init(string: self.searchUrl)!)
                            
                            searchRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                            
                            URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
                                if let data = data {
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            self.parseTracks(json: json)
                                            self.parseAlbums(json: json)
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }.resume()
                        }
                        
                        
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
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
