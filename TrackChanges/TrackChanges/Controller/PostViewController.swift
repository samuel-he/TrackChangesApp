//
//  PostViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/15/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

var SharePost = Int()
var ShareTrack = Track()
var ShareAlbum = Album()

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
        SharePost = Int()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendPost(_ sender: Any) {
        if SharePost == 1 {
            
        } else if SharePost == 2 {
            
        } else {
            var newPost = Post(message: postText.text)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Check if someone is sharing music 
        if SharePost == 1 || SharePost == 2 {
            shareContent.isHidden = false
        } else {
            shareContent.isHidden = true 
        }
        
        if SharePost == 2 {
            playPauseButton.isHidden = true
          
            shareTitle.text = ShareAlbum.name
            shareArtist.text = ShareAlbum.artist.name
            
            shareAlbumCover.contentMode = .scaleAspectFit
            let url = URL.init(string: ShareAlbum.image)!
            do {
                let data = try Data(contentsOf: url)
                shareAlbumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
        } else if SharePost == 1 {
            playPauseButton.isHidden = false
            
            shareTitle.text = ShareTrack.name
            shareArtist.text = ShareTrack.album.artist.name
            
            shareAlbumCover.contentMode = .scaleAspectFit
            let url = URL.init(string: ShareTrack.album.image)!
            do {
                let data = try Data(contentsOf: url)
                shareAlbumCover.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        postText.text = "What are you listening to?"
        postText.textColor = UIColor.lightGray
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

        
//        if playerState.isPaused {
//            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
//        } else {
//            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
//        }
        
        // Check if the current song being shared is playing
//        if playerState.track.name == ShareTitle || playerState.track.album.name == ShareTitle {
//            playPauseButton.setImage(UIImage.init(named: "Navigation_Pause_2x"), for: .normal)
//        } else {
//            playPauseButton.setImage(UIImage.init(named: "Navigation_Play_2x"), for: .normal)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
