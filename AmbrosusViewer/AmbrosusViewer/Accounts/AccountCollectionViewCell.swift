//
//  Copyright: Ambrosus Inc.
//  Email: tech@ambrosus.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
// (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

        if AccountsManager.sharedInstance.getPublicKey() == account.publicKey {
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
