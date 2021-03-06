//
//  ProfileTableViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/24/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var followingCount: UIButton!
    @IBOutlet weak var followersCount: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
