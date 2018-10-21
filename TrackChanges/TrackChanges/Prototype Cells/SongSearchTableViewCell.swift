//
//  SongSearchTableViewCell.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/21/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class SongSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var songTitle: UILabel!
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
