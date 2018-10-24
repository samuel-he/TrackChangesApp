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

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playAndPauseSong(_ sender: Any) {
        let sender = sender as! PlayPauseButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Dynamic cell size
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = CGSize(width: 1, height: 1)
    }
    
    // Create a post 
    @IBAction func createPost(_ sender: Any) {
        self.performSegue(withIdentifier: "StartPost", sender: nil) 
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCollectionViewCell
        
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
