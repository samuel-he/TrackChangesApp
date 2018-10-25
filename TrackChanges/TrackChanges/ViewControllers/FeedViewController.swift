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

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var feedTitleLabel: UILabel!
    var tapToTheTop: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add gesture recognizer to move to the top on click
        tapToTheTop = UITapGestureRecognizer(target: self, action: #selector(scrollToTop))
        feedTitleLabel.addGestureRecognizer(tapToTheTop)
        
        tableView.estimatedRowHeight = 365
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /*****
    **** Tap to reload to top of the screen
    *****/
    @objc func scrollToTop() {
        tableView.setContentOffset(.zero, animated: true)
    }
    
    @IBAction func playAndPauseSong(_ sender: Any) {
        let sender = sender as! PlayPauseButton
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
