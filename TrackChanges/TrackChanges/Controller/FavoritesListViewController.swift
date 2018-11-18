//
//  FavoritesListViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 11/4/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class FavoritesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    @IBOutlet weak var displayTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.title = "Songs"
        } else if FavoritesDisplayCategory == 1 {
            self.title = "Albums"
        } else {
            self.title = "Shared"
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

}
