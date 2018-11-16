//
//  AlbumViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //////
    // Start a post about a track
    //////
    
    @IBAction func shareTrack(_ sender: Any) {
        let sender = sender as! UIButton
        SharePost = 1
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
            cell.postButton.tag = indexPath.row - 1
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Play selected song
//        AppRemote.playerAPI?.play(SelectedAlbum.tracks[indexPath.row - 1].uri, callback: { (track, error) in
//            print(error?.localizedDescription)
//        })
        
        AppRemote.playerAPI?.play(SelectedAlbum.tracks[indexPath.row - 1].uri, callback: defaultCallback)
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
