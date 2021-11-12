//
//  MessageTVCell.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/13.
//

import UIKit

class MessageTVCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    
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
        contentView.layer.cornerRadius = 16
        let padding = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 16)
        contentView.frame = contentView.frame.inset(by: padding)
    }
}
