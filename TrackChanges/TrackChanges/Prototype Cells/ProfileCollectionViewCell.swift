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
        
        // Add border to cell
        self.layer.borderColor = UIColor.init(red: 109/255, green: 109/255, blue: 109/255, alpha: 1).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
}
