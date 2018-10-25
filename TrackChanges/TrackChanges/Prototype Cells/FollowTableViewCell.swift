//
//  FollowTableViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/14/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width / 2 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
