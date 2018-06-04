//
//  Copyright: Ambrosus Technologies GmbH
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

final class ModuleDetailCollectionViewCell: UICollectionViewCell {

    static let itemSpacing: CGFloat = 10

    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        stackView.spacing = ModuleDetailCollectionViewCell.itemSpacing
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
    }

    static func getHeight(forNumberOfSectionTypes numberOfSectionTypes: CGFloat) -> CGFloat {
        let titleInfoViewHeight: CGFloat = 35.5 + itemSpacing
        let titleInfoViewsHeight: CGFloat = titleInfoViewHeight * numberOfSectionTypes
        let cellBottomPadding: CGFloat = 20
        let stackViewTopAndBottomPadding: CGFloat = 30
        let stackViewHeight = titleInfoViewsHeight + stackViewTopAndBottomPadding
        let cellHeight = stackViewHeight + cellBottomPadding
        return cellHeight
    }

    private func getStringValue(for value: Any) -> String? {
        if let stringValue = value as? String {
            return stringValue
        } else if let intValue = value as? Int {
            return intValue.description
        } else if let floatValue = value as? Float {
            return floatValue.description
        } else if let arrayFirstValue = (value as? [Any])?.first {
            return getStringValue(for: arrayFirstValue)
        }
        return nil
    }

    func populate(with data: [String: Any]) {
        stackView.removeAllArrangedSubviews()

        for key in data.keys {
            if let value = data[key], let info = getStringValue(for: value) {
                let titleInfoView = TitleInfoView()
                titleInfoView.setup(withTitle: key, info: info)
                stackView.addArrangedSubview(titleInfoView)
            }
        }
    }
}

fileprivate extension UIStackView {

    func removeAllArrangedSubviews() {
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

}
