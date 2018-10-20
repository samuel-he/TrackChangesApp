//
//  AlbumCoverTableViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class AlbumCoverTableViewCell: UITableViewCell {

    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
