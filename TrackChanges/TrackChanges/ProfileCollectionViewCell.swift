//
//  ProfileCollectionViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/18/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var followingCount: UIButton!
    @IBOutlet weak var followersCount: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    override func layoutSubviews() {
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width / 2
    }
}
