//
//  PostTableViewCell.swift
//  FireMessage
//
//  Created by Connor Wybranowski on 2/7/16.
//  Copyright © 2016 Wybro. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
