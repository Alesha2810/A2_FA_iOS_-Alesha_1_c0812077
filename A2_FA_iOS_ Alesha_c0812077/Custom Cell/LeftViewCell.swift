//
//  LeftViewCell.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 25/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit

class LeftViewCell: UITableViewCell {
    @IBOutlet var lblName : UILabel!
    @IBOutlet var imgPic : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
