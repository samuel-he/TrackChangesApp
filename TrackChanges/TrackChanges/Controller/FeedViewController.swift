//
//  FeedViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/13/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Mini player stuff
    var miniPlayer: MiniPlayerViewController?
    var currentSong: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large title in navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // Segue for miniplayer
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "miniPlayer", let destination = segue.destination as? MiniPlayerViewController {
//            miniPlayer = destination
//            miniPlayer?.delegate = self as? MiniPlayerDelegate
//        }
//    }
    
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
            cell.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
        }
        
        // Add a tag to identify which cell was selected
        cell.playPauseButton.tag = indexPath.row
        return cell
    }
    
}

