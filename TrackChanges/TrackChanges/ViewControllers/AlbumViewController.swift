//
//  AlbumViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import AVFoundation

var AlbumSongs = [String]()
var CurrentSongIndex = Int()

class AlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //////
    // Start a post about a track
    //////
    
    @IBAction func shareTrack(_ sender: Any) {
        SharePost = true
    }
    
    //////
    // Start a post about an album
    //////
    
    @IBAction func shareAlbum(_ sender: Any) {
        SharePost = true
        
        // Set info for share post
//        ShareTitle = (songTitle.text as? String)!
//        ShareAlbum = albumCover.image!
//        ShareArtist = (artist.text as? String)!
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCoverTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! AlbumSongTableViewCell
            cell.postButton.tag = indexPath.row - 1
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row != 0 {
//            do {
//                let audioPath = Bundle.main.path(forResource: AlbumSongs[indexPath.row], ofType: ".mp3")
//                try AudioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)
//                AudioPlayer.play()
//                // Set index of current song in album array 
//                CurrentSongIndex = indexPath.row
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
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
