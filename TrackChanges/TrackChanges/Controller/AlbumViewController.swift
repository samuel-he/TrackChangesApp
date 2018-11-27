//
//  AlbumViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var miniPlayer: MiniPlayerViewController?

    @IBOutlet weak var table: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.table.reloadData()
    }
    
    //////
    // Start a post about a track
    //////
    
    @IBAction func shareTrack(_ sender: Any) {
        let sender = sender as! UIButton
        SharePost = 1
        ShareFromSongView = false
        // Set track to share
        ShareTrack = SelectedAlbum.tracks[sender.tag]
    }
    
    //////
    // Start a post about an album
    //////
    
    @IBAction func shareAlbum(_ sender: Any) {
        SharePost = 2
        ShareAlbum = SelectedAlbum
    }
    
    /*****
    *** Go back to the previous screen
    *******/
    
    @IBAction func previous(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 390
        } else {
            return 60 
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectedAlbum.tracks.count + 1 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCoverTableViewCell
            cell.albumTitle.text = SelectedAlbum.name
            cell.artist.text = SelectedAlbum.artist.name
            
            cell.albumCover.contentMode = .scaleAspectFit
            let url = URL.init(string: SelectedAlbum.image)!
            do {
                let data = try Data(contentsOf: url)
                cell.albumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! AlbumSongTableViewCell
            cell.trackNumber.text = String(describing: indexPath.row)
            cell.songTitle.text = SelectedAlbum.tracks[indexPath.row - 1].name
            if GuestUser {
                cell.postButton.isHidden = true
            } else {
                cell.postButton.isHidden = false 
                cell.postButton.tag = indexPath.row - 1
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Play selected song
//        AppRemote.playerAPI?.play(SelectedAlbum.tracks[indexPath.row - 1].uri, callback: { (track, error) in
//            print(error?.localizedDescription)
//        })
//        AppRemote.playerAPI?.pause(defaultCallback)
        AppRemote.playerAPI?.play(SelectedAlbum.tracks[indexPath.row - 1].uri, callback: defaultCallback)
        SelectedAlbumIndex = indexPath.row - 1
        AppRemote.playerAPI?.getPlayerState(defaultCallback)
        
        /*
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        let tokenUrl = "https://accounts.spotify.com/api/token"
        
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
                        
                        // Make request
                        var requestUrl = "https://api.spotify.com/v1/tracks/"
                        requestUrl += SelectedAlbum.tracks[indexPath.row - 1].id
                        
                        
                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if let data = data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        
                                        var trackTemp: String = ""
                                        var artistTemp: String = ""
                                        var imageTemp: String = ""
                                        
                                        if let trackName = json["name"] as? String {
                                            print("TRACK NAME: ", trackName)
//                                            feedPost.track.name = trackName
                                            trackTemp = trackName
                                            print("TRACK: ", json["name"] as? String)
                                        }
                                        
                                        if let artists = json["artists"] as? [[String: Any]] {
                                            if let artist = artists[0] as? [String: Any] {
                                                if let artistName = artist["name"] as? String {
//                                                    feedPost.track.album.artist.name = artistName
                                                    artistTemp = artistName
                                                }
                                            }
                                        }
                                        
                                        if let album = json["album"] as? [String: Any] {
                                            if let images = album["images"] as? [[String: Any]] {
                                                if let imageUrl = images[1]["url"] as? String {
                                                    imageTemp = imageUrl
//                                                    feedPost.track.album.image = imageUrl
                                                }
                                            }
                                        }
//                                        self.miniPlayer?.updatePlayer(track: trackTemp, artist: artistTemp, imageurl: imageTemp)
                                        
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
        */
        NotificationCenter.default.post(name: Notification.Name.init("getPlayerState"), object: nil)
    }

    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(style: .normal, title: "Like") { (action, view, handler) in
            // TODO
        }
        action.backgroundColor = UIColor.orange
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(style: .normal, title: "Share") { (action, view, handler) in
            SharePost = 1
            // Set track to share
            ShareTrack = SelectedAlbum.tracks[indexPath.row - 1]
            ShareFromSongView = false
            
            self.performSegue(withIdentifier: "ShareTrackFromAlbum", sender: nil)
            
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
