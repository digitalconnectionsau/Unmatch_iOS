//
//  CategoryTVCell.swift
//  unmatch
//
//  Created by Xiao Long on 2021/7/11.
//

import UIKit

class CategoryTVCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    
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
        contentView.layer.cornerRadius = 24
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor(red: 241 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1).cgColor
        let padding = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        contentView.frame = contentView.frame.inset(by: padding)
    }
}
