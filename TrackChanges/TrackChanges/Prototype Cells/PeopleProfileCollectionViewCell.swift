//
//  PeopleProfileCollectionViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/21/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class PeopleProfileCollectionViewCell:  ProfileCollectionViewCell {
    
    @IBOutlet weak var followButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        followButton.layer.borderColor = UIColor.black.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 5
    }
}
