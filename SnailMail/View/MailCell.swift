//
//  MailCell.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class MailCell: UITableViewCell {
    
    var mail: Mail!
    
    @IBOutlet weak var mailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mailImageView.image = kBLANKIMAGE
        nameLabel.text = mail.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
