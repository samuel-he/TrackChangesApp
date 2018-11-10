//
//  PostViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/15/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

var SharePost = Bool()

var ShareTitle = String()
var ShareAlbum = UIImage()
var ShareArtist = String()
var ShareTrackID = String() 

class PostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var shareContent: UIView!
    @IBOutlet weak var shareAlbumCover: UIImageView!
    @IBOutlet weak var shareTitle: UILabel!
    @IBOutlet weak var shareArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        getPlayerState()
    }
    
    // Dismiss PostViewController
    @IBAction func exitPost(_ sender: Any) {
        SharePost = false 
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if someone is sharing music 
        if SharePost {
            shareContent.isHidden = false
        } else {
            shareContent.isHidden = true 
        }
        
        postText.text = "What are you listening to?"
        postText.textColor = UIColor.lightGray
        
        shareArtist.text = ShareArtist
        shareAlbumCover.image = ShareAlbum
        shareTitle.text = ShareTitle

    }
    
    override func viewDidAppear(_ animated: Bool) {
        postText.becomeFirstResponder()
        
        postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            postText.text = "What are you listening to?"
            postText.textColor = UIColor.lightGray
            
            postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
        } else if postText.textColor == UIColor.lightGray && !text.isEmpty {
            postText.textColor = UIColor.black
            postText.text = text
        } else {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if postText.textColor == UIColor.lightGray {
                postText.selectedTextRange = postText.textRange(from: postText.beginningOfDocument, to: postText.beginningOfDocument)
            }
        }
    }
    
    // MARK: Update now playing view
    
    func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        self.shareTitle.text = playerState.track.name
        self.shareArtist.text = playerState.track.artist.name
        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
            self.updateAlbumArtWithImage(image)
        }
        
//        if playerState.isPaused {
//            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
//        } else {
//            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
//        }
        
        // Check if the current song being shared is playing
        if playerState.track.name == ShareTitle || playerState.track.album.name == ShareTitle {
            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
        }
    }
    
    func updateAlbumArtWithImage(_ image: UIImage) {
        self.shareAlbumCover.image = image
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        self.shareAlbumCover.layer.add(transition, forKey: "transition")
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        //        self.PlayerState = playerState
        PlayerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        AppRemote.imageAPI?.fetchImage(forItem: track, with: CGSize(width: 80, height: 80), callback: { (image, error) -> Void in
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
