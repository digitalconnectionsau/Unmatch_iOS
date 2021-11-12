//
//  ExTVCell.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import UIKit

class ExTVCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        contentView.frame = contentView.frame.inset(by: padding)
        contentView.layer.cornerRadius = 16
    }
}
