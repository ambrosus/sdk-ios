//
//  CreationTextFieldTableViewCell.swift
//  AmbrosusViewer
//
//  Created by MaximCh on 3/20/19.
//  Copyright © 2019 Ambrosus Inc. All rights reserved.
//

import UIKit

class CreationTextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static func cellIdentifier() -> String {
        return String(describing: CreationTextFieldTableViewCell.self)
    }

    static func cellHeight() -> CGFloat {
        return 84
    }
}
