//
//  FeedCollectionViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/14/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    override func layoutSubviews() {
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width / 2 
    }
}
