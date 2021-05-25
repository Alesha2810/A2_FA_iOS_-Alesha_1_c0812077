//
//  ProductCell.swift
//  A2_FA_iOS_ Alesha_c0812077
//
//  Created by Alesha on 24/05/21.
//  Copyright © 2021 XYZ. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet var vBackground: UIView!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblProductDesc: UILabel!
    @IBOutlet var lblProductPrice: UILabel!
    @IBOutlet var lblProductProvider: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        vBackground.layer.cornerRadius = 8
        vBackground.layer.masksToBounds = true
        
        appDelegate.setShadow(self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
