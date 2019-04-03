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

final class StandardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var disclosureImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    let visibleBackgroundArea = UIView()

    static let height: CGFloat = 44

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = Colors.colorElement2
        descriptionLabel.textColor = Colors.darkElement3
        descriptionLabel.font = Fonts.cellDescription
        titleLabel.font = Fonts.cellTitle

        visibleBackgroundArea.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(visibleBackgroundArea, at: 0)
        visibleBackgroundArea.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        visibleBackgroundArea.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        visibleBackgroundArea.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visibleBackgroundArea.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func setupCell(withAsset asset: AMBAsset, isLastCell: Bool) {
        titleLabel.text = asset.name ?? asset.id
        descriptionLabel.text = asset.date

        // The last cell in a section shouldn't have a separator
        separatorView.isHidden = isLastCell
    }

    func setupCell(withTitle title: String, color: UIColor? = Colors.colorElement2, isLastCell: Bool = false) {
        titleLabel.text = title
        titleLabel.textColor = color
        disclosureImageView?.tintColor = color
        descriptionLabel.text = String()

        // The last cell in a section shouldn't have a separator
        separatorView.isHidden = isLastCell
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.visibleBackgroundArea.backgroundColor = self.isHighlighted ? Colors.modulePressed : .clear
            }
        }
    }
}
