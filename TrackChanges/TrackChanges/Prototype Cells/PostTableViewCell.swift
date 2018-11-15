//
//  PostTableViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/24/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playPauseButton: PlayPauseButton!
    
    override func layoutSubviews() {
//        self.profilePic.layer.cornerRadius = self.profilePic.frame.width / 2
        // Add border to cell
//        self.layer.borderColor = UIColor.init(red: 109/255, green: 109/255, blue: 109/255, alpha: 1).cgColor
//        self.layer.borderWidth = 1
//        self.layer.cornerRadius = 5
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
