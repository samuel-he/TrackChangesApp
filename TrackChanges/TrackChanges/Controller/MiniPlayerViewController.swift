//
//  MiniPlayerViewController.swift
//  TrackChanges
//
//  Created by Pavly Habashy on 11/15/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

var SelectedAlbumIndex = Int()

class MiniPlayerViewController: UIViewController, SPTAppRemotePlayerStateDelegate {
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    
    var currentSong: Track?
//    weak var delegate: MiniPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlayerState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPlayerState()
        
        // Add a top border to the mini player
        self.view.addTopBorder(color: UIColor.lightGray, width: 0.2)
        
        // Round the album cover art in the mini player (NOT WORKING)
        //        miniPlayer?.thumbImage.layer.cornerRadius = 3.0
        //        miniPlayer?.thumbImage.clipsToBounds = true
        //        currentSong = Track()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayer), name: Notification.Name.init("getPlayerState"), object: nil)
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
    @objc func getPlayerState() {
        print("HERE")
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
    
    @IBAction func swipedUp(_ sender: Any) {
        self.performSegue(withIdentifier: "miniPlayerToSongView", sender: sender)
    }
    
    @objc func updatePlayer() {
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
                        requestUrl += SelectedAlbum.tracks[SelectedAlbumIndex].id
                        
                        
                        var request = URLRequest(url: URL.init(string: requestUrl)!)
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
                        URLSession.shared.dataTask(with: request) { (data, response, error) in
                            if let data = data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        
//                                        var trackTemp: String = ""
//                                        var artistTemp: String = ""
//                                        var imageTemp: String = ""
                                        
                                        if let trackName = json["name"] as? String {
                                            print("TRACK NAME: ", trackName)
                                            //                                            feedPost.track.name = trackName
                                            self.songTitle.text = trackName
                                            print("TRACK: ", json["name"] as? String)
                                        }
                                        
                                        if let artists = json["artists"] as? [[String: Any]] {
                                            if let artist = artists[0] as? [String: Any] {
                                                if let artistName = artist["name"] as? String {
                                                    //                                                    feedPost.track.album.artist.name = artistName
                                                    self.nowPlayingArtist.text = artistName
                                                }
                                            }
                                        }
                                        
                                        if let album = json["album"] as? [String: Any] {
                                            if let images = album["images"] as? [[String: Any]] {
                                                if let imageUrl = images[1]["url"] as? String {
                                                    do {
                                                        let data = try Data(contentsOf: URL.init(string: imageUrl)!)
                                                        self.thumbImage.image = UIImage.init(data: data)
                                                    } catch {
                                                        
                                                    }
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
    }
    
}


extension MiniPlayerViewController {
//    func updatePlayer(track: String, artist: String, imageurl: String) {
//        songTitle.text = track
//        nowPlayingArtist.text = artist
//        do {
//            let data = try Data(contentsOf: URL.init(string: imageurl)!)
//            thumbImage.image = UIImage.init(data: data)
//        } catch {
//
//        }
//        print("YEP")
//    }
}
