//
//  TagCell.swift
//  IroIro
//
//  Created by neoman nouiouat on 6/6/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var count: UILabel!
    
    var color: UIColor!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //setupCell()
    }
    
    func setupCell() {
        name.textColor = color
        count.textColor = Colors.darker(color)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
