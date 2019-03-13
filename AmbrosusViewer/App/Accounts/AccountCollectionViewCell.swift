//
//  AccountCollectionViewCell.swift
//  AmbrosusViewer
//
//  Created by Stein, Maxwell on 6/23/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import AmbrosusSDK
import Foundation

class AccountCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var moduleView: ModuleView!
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var isSignedInLabel: UILabel!
    @IBOutlet weak var publicKeyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false
        isSignedInLabel.text = "Signed In"
    }

    func setup(withAccount account: AMBAccount) {
        accountImageView.image = account.image
        accountNameLabel.text = account.name
        publicKeyLabel.text = account.publicKey

        if AMBUserSession.sharedInstance.signedInUserPublicKey == account.publicKey {
            isSignedInLabel.isHidden = false
            accountNameLabel.textColor = Colors.darkElement1
            moduleView.layer.shadowColor = Colors.deepShadow?.cgColor
        } else {
            isSignedInLabel.isHidden = true
            accountNameLabel.textColor = Colors.colorElement2
            moduleView.layer.shadowColor = Colors.shadowColor?.cgColor
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.moduleView.backgroundColor = self.isHighlighted ? Colors.modulePressed : Colors.module
            }
        }
    }
}
