//
//  ISSPasstimeTableViewCell.swift
//  ISS_Passtime
//
//  Created by Jagadish R Hattigud on 06/03/18.
//  Copyright © 2018 Jagadish R Hattigud. All rights reserved.
//

import UIKit

class ISSPasstimeTableViewCell: UITableViewCell {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var risetimeLabel: UILabel!
    @IBOutlet weak var durationTextDisplay: UITextField!
    
    @IBOutlet weak var risetimeTextDisplay: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
