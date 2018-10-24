//
//  SongViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import AVFoundation

var AudioPlayer = AVAudioPlayer()

class SongViewController: UIViewController {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Set title of song and album
    }
    
    @IBAction func postSong(_ sender: Any) {
        SharePost = true 
    }
    
    @IBAction func playAndPauseSong(_ sender: Any) {
        if !AudioPlayer.isPlaying {
            AudioPlayer.play()
            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        } else if AudioPlayer.isPlaying {
            AudioPlayer.pause()
            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
        }
    }
    
    @IBAction func playNextSong(_ sender: Any) {
        if CurrentSongIndex < AlbumSongs.count - 1 {
            do {
                let audioPath = Bundle.main.path(forResource: AlbumSongs[CurrentSongIndex + 1], ofType: ".mp3")
                try AudioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)
                AudioPlayer.play()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func playPreviousSong(_ sender: Any) {
        if CurrentSongIndex > 0 {
            do {
                let audioPath = Bundle.main.path(forResource: AlbumSongs[CurrentSongIndex - 1], ofType: ".mp3")
                try AudioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)
                AudioPlayer.play()
            } catch {
                print(error.localizedDescription)
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
